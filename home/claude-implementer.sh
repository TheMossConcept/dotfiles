cd $1
# Make the plan and implement it
export IMPLEMENTATION_PLAN_PATH=$(claude --dangerously-skip-permissions --output-format json -p "Could you please have the implementation planner make a detailed implementation for the following user story: '$2'. Output only the relative path to the plan" | jq -r '.result')
claude --dangerously-skip-permissions --output-format json -p "Could you please have the backend architect implement the backend parts of the implementation plan found at: ${IMPLEMENTATION_PLAN_PATH}"
claude --dangerously-skip-permissions --output-format json -p "Could you please have the frontend architect implement the frontend parts of the implementation plan found at: ${IMPLEMENTATION_PLAN_PATH}"

# Make the refactor plan and implement it
export REFACTOR_PLAN_PATH=$(claude --dangerously-skip-permissions --output-format json -p "Could you please have the refactor planner make a detailed refactor plan for the last two commits. Output only the relative path to the plan" | jq -r '.result')
claude --dangerously-skip-permissions --output-format json -p "Could you please have the backend architect implement the backend parts of the refactor plan found at: ${REFACTOR_PLAN_PATH}"
claude --dangerously-skip-permissions --output-format json -p "Could you please have the frontend architect implement the frontend parts of the refactor plan found at: ${REFACTOR_PLAN_PATH}"

# Correct any potential errors
claude --dangerously-skip-permissions --output-format json -p  "Could you please verify that both the frontend and backend builds without errors, and that the application runs without showing any errors in the console or in the user interface. If you encounter any issues, please hand them over to the root cause analyst to fix and include as much detail about them as possible"
