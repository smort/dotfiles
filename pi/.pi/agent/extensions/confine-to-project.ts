import * as os from "node:os"
import * as path from "node:path"
import { isToolCallEventType } from "@mariozechner/pi-coding-agent"
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent"

/**
 * Guards file writes outside the project directory.
 *
 * - write / edit : deterministic path check; prompts the user to allow or deny.
 * - bash         : best-effort detection of redirect targets, cp/mv destinations,
 *                  and mkdir targets that resolve outside the project root.
 *                  Prompts the user to allow or deny when detected.
 *
 * False-positive improvements over the naïve approach
 * ---------------------------------------------------
 * Previous version flagged bash commands whenever *any* home-directory path
 * appeared together with *any* redirect, regardless of whether the redirect
 * actually pointed outside the project. Common false-positive patterns:
 *
 *   cp ~/dotfile .          ← source is outside, but destination is in project
 *   cat ~/cfg | grep x > ./out.txt  ← redirect target is relative/in project
 *   cmd > /dev/null         ← /dev/ paths are always exempt
 *
 * This version extracts the *actual* redirect target, the *actual* cp/mv
 * destination, and the *actual* mkdir path before checking each against the
 * project root.  /dev/ paths are always allowed.
 *
 * In interactive mode (ctx.hasUI) the user is prompted before blocking.
 * In non-interactive mode the call is blocked automatically.
 */

// ── helpers ────────────────────────────────────────────────────────────────

function isOutsideProject(resolved: string, projectRoot: string): boolean {
  return !resolved.startsWith(projectRoot + path.sep) && resolved !== projectRoot
}

/** Expand leading `~` to the home directory. */
function expandTilde(p: string, home: string): string {
  if (p === "~") return home
  if (p.startsWith("~/")) return home + p.slice(1)
  return p
}

/**
 * Paths starting with /dev/ are always benign (e.g. /dev/null, /dev/stderr).
 * Skip them to avoid noisy false positives.
 */
function isDevPath(p: string): boolean {
  return p.startsWith("/dev/")
}

/**
 * Extract the destination paths of redirect operators (> / >>).
 * Only returns absolute or tilde-prefixed paths — relative paths resolve
 * to cwd (inside the project) and are not interesting.
 */
function extractRedirectTargets(cmd: string, home: string): string[] {
  const targets: string[] = []
  // Optional fd prefix (1, 2, &), then > or >>, then optional whitespace,
  // then a path that starts with ~ or /
  const re = /(?:[12&])?>>?\s*(~[^\s;|&'"<>]*|\/[^\s;|&'"<>]*)/g
  let m: RegExpExecArray | null
  while ((m = re.exec(cmd)) !== null) {
    targets.push(expandTilde(m[1], home))
  }
  return targets
}

/**
 * Extract the *destination* of a cp or mv command (last non-flag positional arg).
 * Returns null if the destination cannot be determined or is a relative path.
 */
function extractCpMvDest(cmd: string, home: string): string | null {
  const tokens = cmd.trim().split(/\s+/)
  const cmdIdx = tokens.findIndex(
    (t) => t === "cp" || t === "mv" || t.endsWith("/cp") || t.endsWith("/mv"),
  )
  if (cmdIdx === -1) return null
  // Collect positional args after the command name (skip flags)
  const args = tokens.slice(cmdIdx + 1).filter((t) => t.length > 0 && !t.startsWith("-"))
  if (args.length < 2) return null
  const dest = args[args.length - 1]
  // Only care about absolute or tilde-based destinations
  if (!dest.startsWith("/") && !dest.startsWith("~")) return null
  return expandTilde(dest, home)
}

/**
 * Extract mkdir target paths (absolute or tilde-based).
 */
function extractMkdirTargets(cmd: string, home: string): string[] {
  const targets: string[] = []
  const tokens = cmd.trim().split(/\s+/)
  let collecting = false
  for (const token of tokens) {
    if (token === "mkdir" || token.endsWith("/mkdir")) {
      collecting = true
      continue
    }
    if (!collecting) continue
    // Shell operators end the mkdir argument list
    if (token === "&&" || token === "||" || token === ";" || token === "|") {
      collecting = false
      continue
    }
    if (token.startsWith("-")) continue // flag
    if (token.startsWith("/") || token.startsWith("~")) {
      targets.push(expandTilde(token, home))
    }
  }
  return targets
}

// ── extension ──────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  // Inject a system-prompt rule so the LLM doesn't try to work around blocks
  pi.on("before_agent_start", async (event) => {
    return {
      systemPrompt:
        event.systemPrompt +
        "\n\n## File write policy\n" +
        "If a tool call is blocked by an extension (write, edit, or bash), " +
        "do NOT attempt to find an alternative method to accomplish the same operation " +
        "(e.g. using node, python, tee, or any other technique). " +
        "Instead, stop and tell the user what was blocked and why.",
    }
  })

  pi.on("tool_call", async (event, ctx) => {
    const projectRoot = ctx.cwd
    const home = os.homedir()

    // ── write ──────────────────────────────────────────────────────────────
    if (isToolCallEventType("write", event)) {
      const resolved = path.resolve(projectRoot, event.input.path)
      if (isOutsideProject(resolved, projectRoot)) {
        if (ctx.hasUI) {
          const ok = await ctx.ui.confirm(
            "Write outside project?",
            `The agent wants to write to:\n  ${resolved}\n\nThis is outside the project root:\n  ${projectRoot}\n\nAllow this write?`,
          )
          if (ok) return
        }
        return {
          block: true,
          reason: `Blocked: write target "${event.input.path}" resolves outside project root (${projectRoot})`,
        }
      }
    }

    // ── edit ───────────────────────────────────────────────────────────────
    if (isToolCallEventType("edit", event)) {
      const resolved = path.resolve(projectRoot, event.input.path)
      if (isOutsideProject(resolved, projectRoot)) {
        if (ctx.hasUI) {
          const ok = await ctx.ui.confirm(
            "Edit outside project?",
            `The agent wants to edit:\n  ${resolved}\n\nThis is outside the project root:\n  ${projectRoot}\n\nAllow this edit?`,
          )
          if (ok) return
        }
        return {
          block: true,
          reason: `Blocked: edit target "${event.input.path}" resolves outside project root (${projectRoot})`,
        }
      }
    }

    // ── bash ───────────────────────────────────────────────────────────────
    if (isToolCallEventType("bash", event)) {
      const cmd = event.input.command
      const suspicious: string[] = []

      // Redirects whose target resolves outside the project
      for (const target of extractRedirectTargets(cmd, home)) {
        if (!isDevPath(target) && isOutsideProject(target, projectRoot)) {
          suspicious.push(`redirect → ${target}`)
        }
      }

      // cp / mv with a destination outside the project
      const dest = extractCpMvDest(cmd, home)
      if (dest && !isDevPath(dest) && isOutsideProject(dest, projectRoot)) {
        suspicious.push(`cp/mv destination → ${dest}`)
      }

      // mkdir at a path outside the project
      for (const target of extractMkdirTargets(cmd, home)) {
        if (!isDevPath(target) && isOutsideProject(target, projectRoot)) {
          suspicious.push(`mkdir → ${target}`)
        }
      }

      if (suspicious.length > 0) {
        if (ctx.hasUI) {
          const bullets = suspicious.map((s) => `  • ${s}`).join("\n")
          const ok = await ctx.ui.confirm(
            "Bash write outside project?",
            `The agent wants to run:\n  ${cmd}\n\nSuspicious operations:\n${bullets}\n\nProject root: ${projectRoot}\n\nAllow this command?`,
          )
          if (ok) return
        }
        return {
          block: true,
          reason: `Blocked: bash command may write outside the project directory. If this is intentional, perform the operation manually.`,
        }
      }
    }
  })
}
