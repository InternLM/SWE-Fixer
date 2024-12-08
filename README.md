# SWE-Fixer: Open-Source LLMs for Resolving GitHub Issues

SWE-Fixer is a simple yet effective solution for addressing real-world GitHub issues using open-source LLMs. It features a streamlined retrieve-then-edit pipeline with two core components:  
🔍 **A Code File Retriever** and ✏️ **A Code Editor**.

For implementation, we finetune **Qwen2.5-7b** and **Qwen2.5-72b** for the retriever and the editor respectively, leveraging a curated dataset of **100k examples**. SWE-Fixer achieves **state-of-the-art performance** among open-source solutions with open-source models achieving:
- 🔹 **23.3%** on SWE-Bench Lite
- 🔹 **30.2%** on SWE-Bench Verified

🚀 We will release our **fine-tuned models**, **technical report**, **inference code**, and **dataset** soon! Stay tuned!