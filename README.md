# WordPress.org Plugin Deploy - ***Github Action***
This Action commits the contents of your Git tag to the WordPress.org plugin repository using the same tag name. 
It excludes Git-specific items or files and directories as optionally defined in your `.wporgignore` file, and 
moves anything from a `.wordpress-org` subdirectory to the top-level `assets` directory in Subversion (plugin banners, icons, and screenshots).

## Configuration
### Required secrets
* `WORDPRESS_USERNAME`
* `WORDPRESS_PASSWORD`
* `GITHUB_TOKEN` - you do not need to generate one but you do have to explicitly make it available to the Action

Secrets can be set while editing your workflow or in the repository settings. They cannot be viewed once stored. [GitHub secrets documentation](https://developer.github.com/actions/creating-workflows/storing-secrets/)

### Optional environment variables
* `SLUG` - defaults to the respository name, customizable in case your WordPress repository has a different slug. This should be a very rare case as WordPress assumes that the directory and initial plugin file have the same slug.
* `VERSION` - defaults to the tag name; do not recommend setting this except for testing purposes
* `ASSETS_DIR` - defaults to `.wordpress-org`, customizable for other locations of WordPress.org plugin repository-specific assets that belong in the top-level `assets` directory (the one on the same level as `trunk`)
* `IGNORE_FILE` - defaults to `.wporgignore`, customizable for other locations of list of files to be ignore like `.gitignore`
* `ASSETS_IGNORE_FILE` - defaults to `.wporgassetsignore`, customizable for other locations of list of files to be ignore like `.gitignore`

### Excluding files from deployment
If there are files or directories to be excluded from deployment, such as tests or editor config files, they can be specified in your `.wporgignore` file. If you use this method, please be sure to include the following items:

```gitignore
# Directories
.wordpress-org
.github

# Files
/.gitattributes
/.gitignore
```

> **⚠️ Note:** You Should Provide Github Token. If Not No Updated File Will Be Committed & Pushed

## Example Workflow File
```yaml
name: Deploy to WordPress.org
on:
  push:
    branches:
    - refs/tags/*
jobs:
  tag:
    name: New tag
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: WordPress Plugin Deploy
      uses: varunsridharan/action-wp-org-deploy@master
      with:
        WORDPRESS_PASSWORD: ${{ secrets.WORDPRESS_PASSWORD }}
        WORDPRESS_USERNAME: ${{ secrets.WORDPRESS_USERNAME }}
        SLUG: my-super-cool-plugin
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Credits
This Github Action Bootstrapped From 
* [10up/action-wordpress-plugin-deploy](https://github.com/10up/action-wordpress-plugin-deploy)  
* [rtCamp/action-wordpress-org-plugin-deploy](https://github.com/10up/rtCamp/action-wordpress-org-plugin-deploy)  

---
## Change Log
### 1.2 - 29/04/2020
* Improved Logging

### 1.1 - 06/09/2019
* Added Option To Exclude Files When Updating Assets Folder.

### 1.0 - 24/08/2019
* First Release

## Contribute
If you would like to help, please take a look at the list of
[issues][issues] or the [To Do](#-todo) checklist.

## License
Our GitHub Actions are available for use and remix under the MIT license.

## Copyright
2017 - 2018 Varun Sridharan, [varunsridharan.in][website]

If you find it useful, let me know :wink:

You can contact me on [Twitter][twitter] or through my [email][email].

## Backed By
| [![DigitalOcean][do-image]][do-ref] | [![JetBrains][jb-image]][jb-ref] |  [![Tidio Chat][tidio-image]][tidio-ref] |
| --- | --- | --- |

[twitter]: https://twitter.com/varunsridharan2
[email]: mailto:varunsridharan23@gmail.com
[website]: https://varunsridharan.in
[issues]: issues/

[do-image]: https://vsp.ams3.cdn.digitaloceanspaces.com/cdn/DO_Logo_Horizontal_Blue-small.png
[jb-image]: https://vsp.ams3.cdn.digitaloceanspaces.com/cdn/phpstorm-small.png?v3
[tidio-image]: https://vsp.ams3.cdn.digitaloceanspaces.com/cdn/tidiochat-small.png
[do-ref]: https://s.svarun.in/Ef
[jb-ref]: https://www.jetbrains.com
[tidio-ref]: https://tidiochat.com

