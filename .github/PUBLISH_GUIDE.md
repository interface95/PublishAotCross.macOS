# 📤 发布指南

## 🔐 配置 NuGet API Key

### 1. 获取 API Key

1. 访问 [nuget.org](https://www.nuget.org/)
2. 登录账号
3. 进入 `Account Settings` → `API Keys`
4. 点击 `Create`
5. 配置：
   - **Key Name**: `PublishAotCrossXWin.macOS`
   - **Glob Pattern**: `PublishAotCrossXWin.macOS`
   - **Select Scopes**: `Push` 和 `Push new packages and package versions`
   - **Expiration**: 365 天

### 2. 配置 GitHub Secret

1. 在 GitHub 仓库页面，进入 `Settings` → `Secrets and variables` → `Actions`
2. 点击 `New repository secret`
3. 配置：
   - **Name**: `NUGET_API_KEY`
   - **Value**: 粘贴刚才生成的 API Key
4. 点击 `Add secret`

## 🚀 发布新版本

### 方式 1：通过 Git Tag（推荐）

```bash
# 1. 更新版本号
# 编辑 PublishAotCrossXWin.macOS.csproj，修改 <Version>

# 2. 提交更改
git add .
git commit -m "Release v1.0.0"

# 3. 创建并推送 tag
git tag v1.0.0
git push origin v1.0.0

# 4. GitHub Actions 会自动触发发布！
```

### 方式 2：手动触发

1. 进入 GitHub 仓库页面
2. 点击 `Actions` 标签
3. 选择 `Publish to NuGet` 工作流
4. 点击 `Run workflow`
5. 选择分支并点击 `Run workflow`

## 📋 发布流程

当推送 tag 后，GitHub Actions 会自动：

1. ✅ 检出代码
2. ✅ 安装 .NET SDK
3. ✅ 恢复依赖
4. ✅ 构建项目
5. ✅ 打包 NuGet 包
6. ✅ 发布到 NuGet.org
7. ✅ 创建 GitHub Release

## 🔍 查看发布状态

### GitHub Actions 页面

1. 进入 `Actions` 标签
2. 查看最新的工作流运行
3. 点击查看详细日志

### NuGet.org 页面

发布成功后，访问：  
`https://www.nuget.org/packages/PublishAotCrossXWin.macOS`

**注意**：首次发布可能需要几分钟才能在 NuGet.org 上显示。

## 📊 版本号规范

遵循 [语义化版本](https://semver.org/lang/zh-CN/)：

```
主版本号.次版本号.修订号

1.0.0 - 初始版本
1.0.1 - Bug 修复（向后兼容）
1.1.0 - 新功能（向后兼容）
2.0.0 - 破坏性更改（不向后兼容）
```

### 示例

```xml
<!-- Bug 修复 -->
<Version>1.0.1</Version>

<!-- 新功能 -->
<Version>1.1.0</Version>

<!-- 破坏性更改 -->
<Version>2.0.0</Version>
```

## 📝 发布清单

在发布新版本前检查：

- [ ] 更新 `<Version>` 版本号
- [ ] 更新 `README.md` 中的版本号（如果有引用）
- [ ] 测试构建：`dotnet pack -c Release`
- [ ] 验证包内容：`unzip -l *.nupkg`
- [ ] 更新 `CHANGELOG.md`（推荐）
- [ ] 提交所有更改
- [ ] 创建 git tag
- [ ] 推送 tag

## 🛠️ 本地测试

在推送 tag 之前，建议本地测试：

```bash
# 1. 清理
dotnet clean
rm -rf bin obj

# 2. 构建
dotnet build -c Release

# 3. 打包
dotnet pack -c Release

# 4. 查看包内容
unzip -l bin/Release/*.nupkg

# 5. 本地测试
cd /path/to/test-project
dotnet add package PublishAotCrossXWin.macOS \
  --source /path/to/PublishAotCrossXWin.macOS/bin/Release
```

## ❌ 发布失败怎么办？

### 常见问题

#### 1. API Key 无效

**错误**：`403 Forbidden` 或 `401 Unauthorized`

**解决**：
- 检查 GitHub Secret 中的 `NUGET_API_KEY` 是否正确
- 确认 API Key 未过期
- 确认 API Key 有 `Push` 权限

#### 2. 包已存在

**错误**：`409 Conflict - A package with the same ID and version already exists`

**解决**：
- NuGet 不允许覆盖已发布的版本
- 必须更新版本号：`<Version>1.0.1</Version>`
- 重新创建 tag 并推送

#### 3. 包验证失败

**错误**：`Package validation failed`

**解决**：
- 检查 `.nuspec` 是否有必填字段
- 确认 `PackageLicenseExpression` 有效
- 确认 `README.md` 文件存在

## 🔄 撤回已发布的包

**注意**：NuGet 不允许删除包，只能"下架"（unlist）

### 下架包

```bash
# 使用 dotnet CLI
dotnet nuget delete PublishAotCrossXWin.macOS 1.0.0 \
  --api-key YOUR_API_KEY \
  --source https://api.nuget.org/v3/index.json
```

或者在 NuGet.org 网页上：

1. 登录 nuget.org
2. 进入包管理页面
3. 选择要下架的版本
4. 点击 `Unlist`

**效果**：
- ✅ 已安装的用户仍可使用
- ❌ 新用户无法搜索到
- ❌ `dotnet add package` 默认不会安装

## 📈 发布后检查

发布成功后：

1. ✅ 访问 NuGet.org 查看包页面
2. ✅ 测试安装：`dotnet add package PublishAotCrossXWin.macOS`
3. ✅ 检查 GitHub Release 是否创建
4. ✅ 更新文档中的版本号引用
5. ✅ 在 README.md 中添加 NuGet badge

### NuGet Badge

```markdown
[![NuGet](https://img.shields.io/nuget/v/PublishAotCrossXWin.macOS.svg)](https://www.nuget.org/packages/PublishAotCrossXWin.macOS/)
[![Downloads](https://img.shields.io/nuget/dt/PublishAotCrossXWin.macOS.svg)](https://www.nuget.org/packages/PublishAotCrossXWin.macOS/)
```

## 🎯 最佳实践

1. **版本计划**：提前规划版本号
2. **变更日志**：维护 CHANGELOG.md
3. **测试验证**：发布前充分测试
4. **文档更新**：同步更新使用文档
5. **沟通通知**：通知用户重大更新

## 📞 获取帮助

如果遇到问题：

1. 查看 GitHub Actions 日志
2. 检查 NuGet.org 包页面
3. 阅读 [NuGet 文档](https://docs.microsoft.com/nuget/)
4. 提交 Issue

---

💡 **提示**：首次发布建议使用 `0.1.0` 版本进行测试！

