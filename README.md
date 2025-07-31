# wow-addon
Template repository for my WoW addons.

## After copying the template:
1. Rename `PinyinNext.lua` and `PinyinNext.toc` to your addon name
2. Update the start of `development.sh` to define ADDON_NAME as your addon name
3. Make changes to the TOC file:
  - Update `Interface` if this template is old
  - Update `Title` to your addon name
  - Update `Author`
  - Update or remove `SavedVariables`
  - Update `X-Curse-Project-ID`
  - Update name of Lua file to be loaded
4. Update name in `LICENSE`
5. Remove/change boilerplate in main Lua file
6. Create CurseForge project and setup [automatic packaging](https://support.curseforge.com/en/support/solutions/articles/9000197281-automatic-packaging)
