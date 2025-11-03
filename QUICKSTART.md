# Quick Start Guide

## Prerequisites

Install the required tools:

```bash
# 1. Install LLVM (for lld-link)
brew install llvm

# 2. Install xwin (requires Rust/Cargo)
cargo install --locked xwin

# 3. Download Windows SDK
mkdir -p $HOME/.local/share/xwin-sdk
xwin --accept-license splat --output $HOME/.local/share/xwin-sdk
```

## Usage

### Option 1: Use NuGet Package (Recommended)

1. Add to your `.csproj`:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net9.0</TargetFramework>
    <PublishAot>true</PublishAot>
    <AcceptVSBuildToolsLicense>true</AcceptVSBuildToolsLicense>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="PublishAotCrossXWin.macOS" Version="1.0.0" />
  </ItemGroup>
</Project>
```

2. Build:

```bash
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
dotnet publish -r win-x64 -c Release
```

### Option 2: Use Local Clone

1. Clone and patch PublishAotCrossXWin:

```bash
git clone https://github.com/Windows10CE/PublishAotCrossXWin.git $HOME/.local/share/PublishAotCrossXWin
cd $HOME/.local/share/PublishAotCrossXWin

# Patch for macOS support
sed -i '' 's/IsOSPlatform('\''Linux'\'')/IsOSPlatform('\''Linux'\'') or $([MSBuild]::IsOSPlatform('\''OSX'\''))/' src/PublishAotCrossXWin.targets
```

2. Add to your `.csproj`:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net9.0</TargetFramework>
    <PublishAot>true</PublishAot>
    <XWinCache>$(HOME)/.local/share/xwin-sdk/</XWinCache>
    <AcceptVSBuildToolsLicense>true</AcceptVSBuildToolsLicense>
  </PropertyGroup>

  <Import Project="$(HOME)/.local/share/PublishAotCrossXWin/src/PublishAotCrossXWin.targets" />
</Project>
```

3. Build:

```bash
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
dotnet publish -r win-x64 -c Release
```

## Output

Your Windows executable will be at:

```
bin/Release/net9.0/win-x64/publish/YourApp.exe
```

Transfer this folder to a Windows machine and run!

## Troubleshooting

| Error | Solution |
|-------|----------|
| `lld-link: command not found` | Add LLVM to PATH: `export PATH="/opt/homebrew/opt/llvm/bin:$PATH"` |
| `Cross-OS native compilation is not supported` | Ensure targets file is imported and `PublishAot=true` |
| `xwin: command not found` | Install xwin: `cargo install --locked xwin` |
| Windows SDK not found | Run: `xwin --accept-license splat --output $HOME/.local/share/xwin-sdk` |

## Next Steps

- See [README.md](README.md) for detailed documentation
- Check [test/Hello.csproj](test/Hello.csproj) for a working example
