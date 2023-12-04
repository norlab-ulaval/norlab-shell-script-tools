<div align="center">
<br>
<br>
<a href="https://norlab.ulaval.ca">
<img src="visual/norlab_logo_acronym_dark.png" width="200">
</a>
<br>

# _NorLab Shell Script Tools (N2ST)_

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

**Note:** Be advise that the repository is still in beta stage and we might introduce breaking change without notice. 

Maintainer: [Luc Coupal](https://redleader962.github.io)


<details>
  <summary style="font-weight: bolder;font-size: x-large;">How to use this repository as a git submodule</summary>

Just clone the *norlab-shell-script-tools* superproject as a submodule in your project repository,
in an arbitrary directory eg.: `my-project/utilities/`.

Procedure
```bash
cd <my-project>
mkdir utilities

git submodule init

git submodule \
  add https://github.com/norlab-ulaval/norlab-shell-script-tools.git \
  utilities/norlab-shell-script-tools

# Commit the submodule to your repository
git add .
git commit -m 'Added norlab-shell-script-tools submodule to repository'
```

### Notes on submodule

To **clone** your repository and its submodule at the same time, use

```bash
git clone --recurse-submodules
```

Be advise, submodules are a snapshot at a specific commit of the *norlab-shell-script-tools*
repository. To **update the submodule** to its latest commit, use

```
[sudo] git submodule update --remote --recursive --init [--force]
```

Notes:

- Add the `--force` flag if you want to reset the submodule and throw away local changes to it.
  This is equivalent to performing `git checkout --force` when `cd` in the submodule root
  directory.
- Add `sudo` if you get an error such
  as `error: unable to unlink old '<name-of-a-file>': Permission denied`

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

### Commiting to submodule from the main project (the one where the submodule is cloned)

#### If you encounter `error: insufficient permission for adding an object to repository database ...`

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

</details>




---

# N2ST shell script function/script library
- Most code in this repository is tested using _**bats-core**_
- Most code is well documented: each script header and each function definition 
- Go to `src/function_library` for shell script functions:
  - docker utilities
  - general utilities
  - prompt utilities
  - teamcity utilities
  - terminal splash
- Go to `src/utility_scripts` for utility script:
  - docker tools installer
  - script that output the host architecture and os 
  - script that output which python version


---

# N2ST testing tools for shell script development

## Setup

1. Copy the `norlab-shell-script-tools/tests/tests_template/` directory in your main project top
   directory and rename it, e.g. `tests_template/` >> `tests_shell/` ( recommand using the
   convention `tests/`);
2. Add project test code in this new test directory.

- See `test_template.bats` for bats test implementation examples;
- Usage: duplicate `test_template.bats` and rename it using the
  convention `test_<logic_or_script_name>.bats`;
- Note: That file is pre-configured to work out of the box, just missing your test logic.

3. Use `run_bats_core_test_in_n2st.bash` to execute your tests. They will be executed in isolation
   in a docker container tailormade for
   testing shell script or command level logic in your codebase.

- Note: test directory nesting is suported
- By default, it will search for the `tests/` directory. Pass your test directory name as an
  argument otherwise.

## To execute shell script tests

Execute your main repository shell script test via 'norlab-shell-script-tools' library

Usage:

```shell
N2ST_PATH="<path/to/submodule/norlab-shell-script-tools>"
source run_bats_core_test_in_n2st.bash ['<test-directory>[/<this-bats-test-file.bats>]' ['<image-distro>']]
```

Arguments:

- `['<test-directory>']`        The directory from which to start test, default to 'tests'
- `['/<this-bats-test-file.bats>']`  A specific bats file to run, default will run all bats file in
  the test directory

---

# References:

### Git Submodules

- [Git Tools - Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Git Submodules: Tips for JetBrains IDEs](https://www.stevestreeting.com/2022/09/20/git-submodules-tips-for-jetbrains-ides/)
- [Git submodule tutorial – from zero to hero](https://www.augmentedmind.de/2020/06/07/git-submodule-tutorial/)

### Bats shell script testing framework references

- [bats-core on github](https://github.com/bats-core/bats-core)
- [bats-core on readthedocs.io](https://bats-core.readthedocs.io)
- `bats` helper library (pre-installed in `norlab-shell-script-tools` testing containers in
  the `tests/` dir)
  - [bats-assert](https://github.com/bats-core/bats-assert)
  - [bats-file](https://github.com/bats-core/bats-file)
  - [bats-support](https://github.com/bats-core/bats-support)
- Quick intro:
  - [testing bash scripts with bats](https://www.baeldung.com/linux/testing-bash-scripts-bats)

