# SWE-Fixer: Open-Source LLMs for Resolving GitHub Issues

SWE-Fixer is a simple yet effective solution for addressing real-world GitHub issues using open-source LLMs. It features a streamlined retrieve-then-edit pipeline with two core components: a code file retriever and a code editor.

For implementation, we fine-tune Qwen-2.5-7b and Qwen-2.5-72b for the retriever and the editor respectively, leveraging a curated dataset of 100k examples. SWE-Fixer obtains SOTA performance among open-source solutions with open-source models, achieving **23.3%** on SWE-Bench Lite and **30.2%** on SWE-Bench Verified.

---

## Authors

<div align="center">
<a href="https://yitianlian.github.io/">Chengxing Xie<sup>1*, 2</sup></a>, 
<a href="https://scholar.google.com/citations?user=RLWXNf8AAAAJ&hl=en">Bowen Li<sup>1*</sup></a>, 
<a href="https://gao-xiao-bai.github.io/">Chang Gao<sup>1*, 3</sup></a>, 
<a href="https://kinza99.github.io/">He Du<sup>1</sup></a>, 
<a href="https://difanzou.github.io/">Difan Zou<sup>4</sup></a>, 
<a href="https://chenkai.site/">Kai Chen<sup>1</sup></a>
</div>

<div align="center">
  <i>* Equal Contribution</i>
</div>

<div align="center">
1. Shanghai AI Laboratory, 2. Xidian University, 3. The Chinese University of Hong Kong, 4. The University of Hong Kong
</div>

## 
