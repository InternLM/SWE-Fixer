BM25_RETRIEVAL_SYS_PROMPT = None

BM25_RETRIEVAL_TASK_NO_REASONING = "In this task, you will be provided with a software development issue from a real-world GitHub repository, along with the repository's README file and a set of preliminarily retrieved files (documentation). Your objective is to carefully analyze the issue in the context of the provided files and identify the most relevant files that are likely candidates for modification to resolve the issue."


BM25_RETRIEVAL_ORACLE_FILE_OUTPUT_CONTROL_NO_REASONING = {
    "files for editing": {"type": "array", "items": {"type": "string"}}
}

EDITING_SYS_PROMPT = None


EDITING_LEVEL_TASK_ONLY_FILE_CONTENT_WITH_REASONING = "In this task, you will be provided with a software development issue from a real-world GitHub repository, along with the full content of retrieved code files for modification. You will also receive narrowed code snippets that are likely candidates for modification. Your objective is to carefully analyze and understand the issue in the context of the provided files, explain your reasoning process for addressing it, and identify the exact file paths and original code snippets that require modification. Based on this analysis, you will propose new code snippets to replace the identified ones to effectively resolve the issue."

EDITING_LEVEL_OUTPUT_CONTROL_WITH_REASONING = {  # for training
    "type": "object",
    "properties": {
        "reasoning process": {
            "type": "string",
        },
        "edited code": {
            "type": "array",
            "items": {
                "type": "object",
                "properties": {
                    "file": {
                        "type": "string",
                    },
                    "code snippet to be modified": {
                        "type": "string",
                    },
                    "edited code snippet": {
                        "type": "string",
                    },
                },
            },
        },
    },
}
