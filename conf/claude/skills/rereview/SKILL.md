---
name: rereview
description: Re-review a PR against prior review comments and draft a pending (unsubmitted) review
argument-hint: [pr-number]
disable-model-invocation: true
---

PR number: $ARGUMENTS

## Tool selection
Check whether tools from a GitHub MCP server are available (their names usually
contain `github`, e.g. `pull_request_read`, `pull_request_review_write`,
`add_comment_to_pending_review`). Tool names change between server versions, so
match by capability, not exact name.
- If available: use MCP for every GitHub read/write below (path A).
- If not available, or an MCP call fails with an auth/permission error: tell me
  once, then use `gh` (path B) for the rest of the run. Don't mix paths for the
  pending-review step.

## 1. Collect prior feedback
- A: `pull_request_read` with methods `get`, `get_reviews`, `get_review_comments`
  (paginate until exhausted) and `get_comments` for the conversation.
  Use the threads' `is_resolved` / `is_outdated` flags directly.
- B: `gh pr view $ARGUMENTS --comments`,
  `gh api --paginate repos/{owner}/{repo}/pulls/$ARGUMENTS/comments` (group
  replies into threads via `in_reply_to_id`),
  `gh api --paginate repos/{owner}/{repo}/pulls/$ARGUMENTS/reviews`. For resolved
  state, query `reviewThreads { isResolved isOutdated }` via `gh api graphql`.
- Either way: note the `commit_id` of the most recent review as BASE, and skip
  resolved threads. If BASE is not an ancestor of the PR head (force-push, bot
  review), use the PR base branch as BASE instead.

## 2. Check out the PR in a worktree
Find the remote that owns the PR (`gh pr view $ARGUMENTS --json baseRepository`),
then:
`git fetch <remote> pull/$ARGUMENTS/head:pr-$ARGUMENTS && git worktree add ../pr-<repository-name>-$ARGUMENTS pr-$ARGUMENTS`
Work only inside that worktree.

## 3. Verify prior feedback
For each open thread, check the current code and mark it
FIXED / PARTIAL / NOT FIXED with a one-line justification.

## 4. New issues
Review `git diff BASE..HEAD` for bugs introduced since the last round.

## 5. Present findings and STOP
Wait for my explicit confirmation. Also say which path (MCP or gh) you will use
to create the review.

## 6. Create the PENDING review (never submit)
Before adding any inline comment, confirm its `path` + `line` is part of the PR
diff (RIGHT side). Move comments on lines outside the diff into the summary body
instead.
First check that I have no existing pending review on this PR: list the reviews
(A: `get_reviews`; B: `gh api .../pulls/$ARGUMENTS/reviews`) and look for one by
me with `state == "PENDING"`. If there is one, stop and tell me.
- A: `pull_request_review_write` with method `create`, `body` = summary, and
  NO `event`. Then add one comment at a time with `add_comment_to_pending_review`
  (`path`, `line`, `side: "RIGHT"`, `subjectType: "LINE"`, `body`).
- B: write JSON to a temp file with `body`, `commit_id` (PR head) and
  `comments` [{path, line, side: "RIGHT", body}], NO `event` field, then
  `gh api repos/{owner}/{repo}/pulls/$ARGUMENTS/reviews --method POST --input <file>`.

FORBIDDEN in this skill: `submit_pending`, `create_and_submit_pull_request_review`,
any `event` value, or `gh pr review`. The review must stay PENDING.

## 7. Verify and clean up
- Read back the pending review's comments and confirm the count matches what you
  intended to post. Report any that are missing.
- Give me the PR link so I can look over the draft and submit it myself.
- `git worktree remove ../pr-<repository-name>-$ARGUMENTS && git branch -D pr-$ARGUMENTS`
