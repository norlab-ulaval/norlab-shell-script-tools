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
  add git@github.com:norlab-ulaval/norlab-shell-script-tools.git \
  utilities/norlab-shell-script-tools

# Commit the submodule to your repository
git add .
git commit -m 'Added norlab-shell-script-tools submodule to repository'
```
## Notes on submodule:

To **clone** your repository and its submodule at the same time, use
```bash
git clone --recurse-submodules
```

Be advise, submodules are a snapshot at a specific commit of the *norlab-shell-script-tools* repository. To **update the submodule** to its latest commit, use
```
git submodule update --remote
```

To set the submodule to **point to a different branch**, use
```bash
git checkout --recurse-submodules the_feature_branch_name
```

#### References:
- [Git Tools - Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
