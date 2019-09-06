#!/bin/bash

set -eo

# Update Github Config.
git config --global user.email "githubactionbot+wp@gmail.com" && git config --global user.name "WP Plugin Publisher"

WORDPRESS_USERNAME="$INPUT_WORDPRESS_USERNAME"
WORDPRESS_PASSWORD="$INPUT_WORDPRESS_PASSWORD"
SLUG="$INPUT_SLUG"
VERSION="$INPUT_VERSION"
ASSETS_DIR="$INPUT_ASSETS_DIR"
IGNORE_FILE="$INPUT_IGNORE_FILE"
ASSETS_IGNORE_FILE="$INPUT_ASSETS_IGNORE_FILE"


# Ensure SVN username and password are set
# IMPORTANT: secrets are accessible by anyone with write access to the repository!
if [[ -z "$WORDPRESS_USERNAME" ]]; then
    echo "Set the WORDPRESS_USERNAME secret"
    exit 1
fi

if [[ -z "$WORDPRESS_PASSWORD" ]]; then
    echo "Set the WORDPRESS_PASSWORD secret"
    exit 1
fi

# Allow some ENV variables to be customized
if [[ -z "$SLUG" ]]; then
    SLUG=${GITHUB_REPOSITORY#*/}
fi

# Does it even make sense for VERSION to be editable in a workflow definition?
if [[ -z "$VERSION" ]]; then
	VERSION=${GITHUB_REF#refs/tags/}
fi

if [[ -z "$ASSETS_DIR" ]]; then
	ASSETS_DIR=".wordpress-org"
fi

if [[ -z "$IGNORE_FILE" ]]; then
	IGNORE_FILE=".wporgignore"
fi

if [[ -z "$ASSETS_IGNORE_FILE" ]]; then
	ASSETS_IGNORE_FILE=".wporgassetsignore"
fi

echo '----------------'
# Echo Plugin Slug
echo "ℹ︎ SLUG is $SLUG"
# Echo Plugin Version
echo "ℹ︎ VERSION is $VERSION"
# Echo Assets DIR
echo "ℹ︎ ASSETS_DIR is $ASSETS_DIR"
echo '----------------'

SVN_URL="http://plugins.svn.wordpress.org/${SLUG}/"
SVN_DIR="/github/svn-${SLUG}"

# Checkout just trunk and assets for efficiency
# Tagging will be handled on the SVN level
echo "➤ Checking out .org repository..."
svn checkout --depth immediates "$SVN_URL" "$SVN_DIR"
cd "$SVN_DIR"
svn update --set-depth infinity assets
svn update --set-depth infinity trunk


echo "➤ Copying files..."
cd "$GITHUB_WORKSPACE"

# "Export" a cleaned copy to a temp directory
TMP_DIR="/github/archivetmp"
ASSET_TMP_DIR="/github/assettmp"
mkdir "$TMP_DIR"
mkdir "$ASSET_TMP_DIR"

echo ".git .github .gitignore .gitattributes ${ASSETS_DIR} ${IGNORE_FILE} ${ASSETS_IGNORE_FILE} node_modules" | tr " " "\n" >> "$GITHUB_WORKSPACE/$IGNORE_FILE"
echo ".psd .DS_Store Thumbs.db ehthumbs.db ehthumbs_vista.db .git .github .gitignore .gitattributes ${ASSETS_DIR} ${IGNORE_FILE} ${ASSETS_IGNORE_FILE} node_modules" | tr " " "\n" >> "$GITHUB_WORKSPACE/$ASSETS_IGNORE_FILE"

#cat "$GITHUB_WORKSPACE/$IGNORE_FILE"

# If there's no .gitattributes file, write a default one into place
if [[ ! -e "$GITHUB_WORKSPACE/$IGNORE_FILE" ]]; then
	# Ensure we are in the $GITHUB_WORKSPACE directory, just in case
	# The .gitattributes file has to be committed to be used
	# Just don't push it to the origin repo :)
	git add "$IGNORE_FILE" && git commit -m "Add $IGNORE_FILE file"
fi
# If there's no .gitattributes file, write a default one into place
if [[ ! -e "$GITHUB_WORKSPACE/$ASSETS_IGNORE_FILE" ]]; then
	# Ensure we are in the $GITHUB_WORKSPACE directory, just in case
	# The .gitattributes file has to be committed to be used
	# Just don't push it to the origin repo :)
	git add "$ASSETS_IGNORE_FILE" && git commit -m "Add $ASSETS_IGNORE_FILE file"
fi

# This will exclude everything in the $IGNORE_FILE file
echo "➤ Removing Exlucded Files From Plugin Source"
rsync -r --delete --exclude-from="$GITHUB_WORKSPACE/$IGNORE_FILE" "./" "$TMP_DIR"

# This will exclude everything in the $ASSETS_IGNORE_FILE file
cd "$ASSETS_DIR"
echo "➤ Removing Exlucded Files From Assets Folder"
rsync -r --delete --exclude-from="$GITHUB_WORKSPACE/$ASSETS_IGNORE_FILE" "./" "$ASSET_TMP_DIR"

cd "$SVN_DIR"

# Copy from clean copy to /trunk, excluding dotorg assets
# The --delete flag will delete anything in destination that no longer exists in source
rsync -rc "$TMP_DIR/" trunk/ --delete

# Copy dotorg assets to /assets
rsync -rc "$ASSET_TMP_DIR/" assets/ --delete

# Add everything and commit to SVN
# The force flag ensures we recurse into subdirectories even if they are already added
# Suppress stdout in favor of svn status later for readability
echo "➤ Preparing files..."
svn add . --force > /dev/null

# SVN delete all deleted files
# Also suppress stdout here
svn status | grep '^\!' | sed 's/! *//' | xargs -I% svn rm % > /dev/null

# Copy tag locally to make this a single commit
echo "➤ Copying tag..."
svn cp "trunk" "tags/$VERSION"

svn status

echo "➤ Committing files..."
svn commit -m "Update to version $VERSION from GitHub" --no-auth-cache --non-interactive  --username "$WORDPRESS_USERNAME" --password "$WORDPRESS_PASSWORD"

echo "✓ Plugin deployed!"