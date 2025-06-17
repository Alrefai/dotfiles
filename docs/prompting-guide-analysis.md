# Prompting Guide Analysis and Agentic Workflow Recommendations

Below is a focused analysis of the "Large projects" and "Modes of interaction"
guidance from the OpenAI Codex CLI Prompting Guide, together with concrete
recommendations for enriching our agentic workflow in this repository to
maximize efficiency and transparency.

Source: [OpenAI Codex CLI Prompting Guide](https://github.com/openai/codex-cli/blob/main/docs/prompting-guide.md)
[1]: https://github.com/openai/codex/blob/main/codex-cli/examples/prompting_guide.md#large-projects

## 1. Key takeaways from the Prompting Guide

| Topic                | Summary                                                                    |
|----------------------|----------------------------------------------------------------------------|
| Shared agent state   | Use a `.codex/` workspace to store agent artifacts (plans, logs, etc).     |
| High-level seeds     | Pre-populate `.codex/requirements.md` with goals, constraints, and scope.  |
| Dynamic planning     | Create dated plan files (e.g. `.codex/plan_YYYY-MM-DD.md`) as you progress.|
| Changelog update     | Append dated entries to `CHANGELOG.md` or `README.md` for major work.      |
| Modes of interaction | Choose interactive vs. full-auto control levels based on task complexity.  |

## 2. Recommended enhancements to our agentic workflow

### A. Introduce a `.codex/` workspace
- **What?** A top-level `.codex/` directory (git-ignored) to hold:
  - `requirements.md` (initial goals & constraints)
  - dated planning files (`plan_YYYY-MM-DD.md`)
  - summaries or logs of completed milestones
- **Why?** Keeps agent state visible, versionable locally, and separate
  from source files.

### B. Seed a high-level requirements document
- **What?** A template `.codex/requirements.md` containing:
  - project mission and scope
  - coding conventions, commit rules, other constraints
  - desired deliverables and milestones
- **Why?** Provides clear upfront context for autonomous planning.

### C. Embed dynamic planning directives
- **What?** Instruct the agent (via `codex.md`) to automatically:
  - create a dated plan file each session (`plan_YYYY-MM-DD.md`)
  - write planned milestones and update them as each phase completes
- **Why?** Offers real-time visibility into the agent’s internal plan.

### D. Automate changelog updates
- **What?** Guide the agent to append a dated entry to `CHANGELOG.md`
  (or `README.md`) for each significant feature or refactor.
- **Why?** Builds an audit trail of “what was done when” for easier review.

### E. Surface modes of interaction
- **What?** Document the difference between:
  - **Interactive mode:** approve each milestone before proceeding
  - **Full-auto mode:** run end-to-end then review at the end
- **Why?** Clarifies user control level and sets interaction expectations.

## 3. Proposed action plan

| Step | Change                                                                |
|:----:|:----------------------------------------------------------------------|
| 1    | Update `codex.md` with an "Agentic Workflow" section.                 |
| 2    | Add a "Modes of interaction" subsection to `codex.md`.                |
| 3    | Create `.codex/requirements.md` and add `.codex/` to `.gitignore`.    |
| 4    | Add a `CHANGELOG.md` template for dated entries of major work.        |
| 5    | Commit changes and push the `codex-setup` branch, then update the PR. |

---

*This file is maintained by the Codex CLI agent. Do not edit manually unless
updating agent configuration or workflows.*
