<div align="center">
<br>
<br>
<a href="https://norlab.ulaval.ca">
<img src="visual/norlab_logo_acronym_dark.png" width="200">
</a>
<br>

# _NorLab Shell Script Tools_

</div>


[//]: # (<b>Project related link: </b> &nbsp; )

[//]: # (Project related link:)
<div align="center">
<p>
<sup>
<a href="https://http://132.203.26.125:8111">NorLab TeamCity GUI</a>
(VPN or intranet access) &nbsp; • &nbsp;  
<a href="https://hub.docker.com/repositories/norlabulaval">norlabulaval</a>
(Docker Hub) &nbsp;
</sup>
</p>  
</div>


Maintainer: [Luc Coupal](https://redleader962.github.io)


## How to use this repository

Just clone the *norlab-shell-script-tools* superproject as a submodule in your project repository, in an arbitrary directory eg.: `my-project/utilities/`.    
```bash
cd my-project

git submodule init

git submodule \
  add https://github.com/norlab-ulaval/norlab-shell-script-tools.git \
  utilities/norlab-shell-script-tools

# Commit the submodule to your repository
git add .
git commit -m 'Added norlab-shell-script-tools submodule to repository'
```

## Notes on submodule

To **clone** your repository and its submodule at the same time, use
```bash
git clone --recurse-submodules
```

Be advise, submodules are a snapshot at a specific commit of the *norlab-shell-script-tools* repository. To **update the submodule** to its latest commit, use
```
[sudo] git submodule update --remote --recursive --init [--force]
```
Notes:
- Add the `--force` flag if you want to reset the submodule and throw away local changes to it. 
  This is equivalent to performing `git checkout --force` when `cd` in the submodule root directory.
- Add `sudo` if you get an error such as `error: unable to unlink old '<name-of-a-file>': Permission denied`

To set the submodule to **point to a different branch**, use
```bash
cd <the/submodule/directory>
git checkout the_submodule_feature_branch_name
```
and use the `--recurse-submodules` flag when switching branch in your main project 
```bash
cd <your/project/root>
git checkout --recurse-submodules the_feature_branch_name
```

---
 
## Commiting to submodule from the main project (the one where the submodule is cloned)

### If you encounter `error: insufficient permission for adding an object to repository database ...`
```shell
# Change the `.git/objects` permissions
cd <main/project/root>/.git/objects/
chown -R $(id -un):$(id -gn) *
#       <yourname>:<yourgroup>

# Share the git repository (the submodule) with a Group
cd ../../<the/submodule/root>/
git config core.sharedRepository group
# Note: dont replace the keyword "group"
```
This should solve the problem permanently.

---

### References:

#### Git Submodules
- [Git Tools - Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Git Submodules: Tips for JetBrains IDEs](https://www.stevestreeting.com/2022/09/20/git-submodules-tips-for-jetbrains-ides/)
- [Git submodule tutorial – from zero to hero](https://www.augmentedmind.de/2020/06/07/git-submodule-tutorial/)

#### Bats shell script testing framework references
- [bats-core on github](https://github.com/bats-core/bats-core)
- [bats-core on readthedocs.io](https://bats-core.readthedocs.io)
- `bats` helper library (pre-installed in `norlab-shell-script-tools` testing containers in the `tests/` dir)
  - [bats-assert](https://github.com/bats-core/bats-assert)
  - [bats-file](https://github.com/bats-core/bats-file)
  - [bats-support](https://github.com/bats-core/bats-support)
- Quick intro: 
  - [testing bash scripts with bats](https://www.baeldung.com/linux/testing-bash-scripts-bats)

