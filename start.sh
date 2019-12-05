#!/bin/sh
set -e

INPUT_BRANCH=${INPUT_BRANCH:-master}
INPUT_FORCE=${INPUT_FORCE:-false}
INPUT_DIRECTORY=${INPUT_DIRECTORY:-'.'}
_FORCE_OPTION=''
REPOSITORY=${INPUT_REPOSITORY:-$GITHUB_REPOSITORY}

echo "Push to branch $INPUT_BRANCH";
[ -z "${INPUT_GITHUB_TOKEN}" ] && {
    echo 'Missing input "github_token: ${{ secrets.GITHUB_TOKEN_WRITE }}".';
    exit 1;
};

[ -z "${INPUT_MAILADDRESS}" ] && {
    echo 'Missing input MailAddress';
    exit 1;
};

if ${INPUT_FORCE}; then
    _FORCE_OPTION='--force'
fi


rm -rf .git

#cd ${INPUT_DIRECTORY}

remote_repo="https://${GITHUB_ACTOR}:${INPUT_GITHUB_TOKEN}@github.com/${REPOSITORY}.git"

git clone "${remote_repo}" push_repo

rsync -av ./ ./push_repo/${INPUT_DIRECTORY}/ --exclude '/push_repo/' --exclude '/.git/' --exclude "/.github/"

cd push_repo

git config --local user.name ${GITHUB_ACTOR}
git config --local user.email ${INPUT_MAILADDRESS}

git add .

git commit -m "Add changes ${INPUT_DIRECTORY}" -a

git push "${remote_repo}" HEAD:${INPUT_BRANCH} --follow-tags $_FORCE_OPTION;
