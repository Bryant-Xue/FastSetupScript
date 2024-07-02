# FastSetupScript
一键配置各项服务器基础设置，包括新建普通用户，配置sudo与sudo免密，配置仅公钥登录增强安全性，更换速度更快的软件源等
## 快速开始
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/Bryant-Xue/FastSetupScript/main/fss.sh)"
```
## 具体功能
1. 执行软件更新
2. 新建普通用户
3. 配置sudo与sudo免密
4. 配置公钥，配置免密登录
5. 关闭密码登录，启用公钥登录（此项可以撤销）

### <font color='red'>请注意检查密码登录关闭后公钥登录是否正确打开，否则可能失联！</font>

## 待办清单
- [x] 新建用户
- [x] 配置sudo与sudo免密
- [x] ssh安全调优
- [ ] 软件源速度优化
- [ ] 支持网络拉取常用参数
- [ ] 支持单行参数传入