---
name: tdd-pipeline
description: TDD pipeline protocol for complex multi-file implementations. Invoke this when a task meets the complexity threshold below.
disable-model-invocation: false
user-invocable: false
---

## When to invoke this pipeline

Use this protocol when the task meets **at least two** of the following:
- Touches 3 or more files
- Creates a new module, package, or significant abstraction
- Introduces a new external dependency or integration
- Contains non-trivial logic (auth, data transformation, concurrency, state management)
- Has clear behavioral contracts that can be specified as tests before implementation

For small changes (a bug fix, a single-file addition, a config tweak) do not use this pipeline — just implement directly.

## Pipeline steps

### 1. Plan
In the current conversation, produce a concrete implementation plan:
- Every file to be created or modified
- Key interfaces, types, and function signatures
- Data flow and dependencies between components
- Edge cases and error conditions to handle

Do not begin writing tests or code until the plan is clear.

### 2. Write tests
Write all tests before any implementation. Save them to the appropriate test files in the project.
- Test behavior, not implementation details
- Cover the happy path, edge cases, and error conditions from the plan
- Tests should be runnable now (they will fail — that is expected)

### 3. Implement via haiku-coder
Invoke the `haiku-coder` agent. Pass it explicitly:
- The full plan from step 1
- The test file paths (or full test content) from step 2
- All existing source files it will need to read to understand context
- A clear instruction: "implement the code to make these tests pass"

Do not summarize or abbreviate the plan when passing it — haiku-coder has no prior context.

### 4. Review
Once haiku-coder returns, review its output in the current conversation (where you have full context):
- Confirm the tests pass (check haiku-coder's reported results)
- Check for security issues, over-engineering, or missed edge cases
- Apply minor fixes directly
- If the implementation needs significant rework, invoke haiku-coder again with specific, targeted feedback on what to fix
