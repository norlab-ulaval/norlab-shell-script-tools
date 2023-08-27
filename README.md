<div align="center">
<br>
<br>
<a href="https://norlab.ulaval.ca">
<img src="visual/norlab_logo_acronym_dark.png" width="200">
</a>
<br>

# _NorLab Project Template_

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

**Note:** This template is for code project implementation. For `latex` project such as writing proposal or conference paper, see the following list of [NorLab `TeX` template repositories](https://github.com/norlab-ulaval?q=template&type=all&language=tex&sort=)  

## How to use this repository template

### Step 1 › Generate the new repository
1. Click on the green `Use this template` button
2. Click on `Create a new repository`
3. Find a meaningful name, don't worry you can change it latter (see BC Gov [Naming Repos](https://github.com/bcgov/BC-Policy-Framework-For-GitHub/blob/master/BC-Gov-Org-HowTo/Naming-Repos.md) recommendation for advice and best-practice)  

### Step 2 › Configure the repository for your project type
(ToDo) Execute `repository_configuration_script.bash` and follow the instructions. You will be asked what kind of project your planning to undergo (latex, ros, python, c++ ...) and the component you wish to add to your repository.

### Step 3 › Configure the _GitHub_ repository settings
(ToDo) Follow the `repository_configuration_checklist.md` steps.
We strongly recommend you to configure repository your branching scheme following Gitflow

```bash
master ← dev ← feature 1
             ↖ feature 2
```
with branch protection rule via pull-request enable for the `master` and the `dev` branches.
The `master` branch is sacred. It must be deployable at any time.  

---
