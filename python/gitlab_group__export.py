"""
1）创建个人访问令牌
https://docs.gitlab.com/ee/user/profile/personal_access_tokens.html

2）下载Python Gitlab包（是Gitlab API的Python包装器)
https://github.com/python-gitlab/python-gitlab

3) 根据代码更改 gitlab_url、gitlab_token、target_groups 变量值运行即可
https://paste.ubuntu.com/p/gC6SNK3cBV/



附注:
如果 GitLab版本大于 12.8 则直接可以用这个API，操作更加方便快捷
https://docs.gitlab.com/ee/api/group_import_export.html

在 GitLab 13.0 中作为实验功能引入，可在页面中直接操作
https://docs.gitlab.com/ee/user/group/settings/import_export.html
"""
import time
import subprocess
import gitlab


def main():

    gitlab_url = 'http://xxx.xxx.com'
    gitlab_token = 'RN2yppNYJJxxxhXKFCk'
    target_groups = ['xxx-cloud', 'xxx-Backend']

    gl = gitlab.Gitlab(gitlab_url, private_token=gitlab_token)
    all_groups = gl.groups.list(all=True)
    group_dict = {group.name: group.id for group in all_groups}

    for target_group in target_groups:
        group = gl.groups.get(group_dict.get(target_group))
        for project in group.projects.list(all=True):
            # p = gl.projects.get(project.id, lazy=True)
            p = gl.projects.get(project.id)
            export = p.exports.create()
            # print(p.__dict__.items())
            export.refresh()
            while export.export_status != 'finished':
                time.sleep(1)
                export.refresh()

            # Download the result
            with open(f'/tmp/{p.name}.tgz', 'wb') as f:
                export.download(streamed=True, action=f.write)

            subprocess.call(f'mkdir -p /tmp/{p.name}', shell=True)
            subprocess.call(f'tar xf /tmp/{p.name}.tgz -C /tmp/{p.name}',
                            shell=True)
            subprocess.call(f'cd /tmp/{p.name} && git clone project.bundle',
                            shell=True)
            subprocess.call(f'rm -f /tmp/{p.name}.tgz', shell=True)


if __name__ == "__main__":
    main()