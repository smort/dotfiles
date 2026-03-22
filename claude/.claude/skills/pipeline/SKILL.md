---
name: pipeline
description: Manually trigger the TDD pipeline for a complex feature implementation.
disable-model-invocation: true
user-invocable: true
argument-hint: [feature description]
---

The user has explicitly triggered the TDD pipeline. Execute the following steps in order. Do not skip ahead.

## Step 1: Plan

Produce a concrete implementation plan and present it to the user before proceeding:
- Every file to be created or modified
- Key interfaces, types, and function signatures
- Data flow and dependencies between components
- Edge cases and error conditions to handle

**Wait for the user to confirm the plan before moving to step 2.** If the user wants changes, revise and confirm again.

## Step 2: Write tests

Write all tests before any implementation. Save them to the appropriate test files.
- Test behavior, not implementation details
- Cover the happy path, edge cases, and error conditions identified in the plan
- Tests should be runnable immediately (they will fail — that is expected and correct)

Tell the user the tests are written and which files they are in before proceeding.

## Step 3: Implement via haiku-coder

Invoke the `haiku-coder` agent. Pass it explicitly:
- The full confirmed plan from step 1
- The test file paths and full test content from step 2
- All existing source files it will need to understand context
- Instruction: "implement the code to make these tests pass, then run the tests and any available linters"

Do not summarize or abbreviate — haiku-coder starts with no context.

## Step 4: Review

Review haiku-coder's implementation against the plan and tests:
- Confirm tests pass (verify haiku-coder's reported results)
- Check for security issues, over-engineering, missed edge cases
- Apply minor fixes directly in the current conversation
- For significant issues, invoke haiku-coder again with specific feedback

Report back to the user: what was implemented, test status, any concerns or decisions worth knowing about.
