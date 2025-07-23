
使用说明

1.CCB 目录下 *.ccb 为游戏中对应 *.ccbi 对应的 UI 编辑

2.编辑器中资源目录和游戏项目中资源目录的对应关系

  Texture 下所有资源目录对应项目工程 Resource 下资源目录

3.游戏中用到很多图集（将一些散图文件通过 TexturePacker 合并为一张整图）
  CocosBuilder UI编辑器无法使用图集
  将 图集资源放在 Resources_Imageset 文件夹中
  
  Resources_Imageset/UI 下每一组散图（合成一张图集的所有小图）放在一个文件夹中
  Resources_Imageset/tps 下放 生成  .plist 和 .png 
  
  在 Windows 系统下执行 imageset.bat 会在当前目录生成 记录所有图集的 Imageset.txt 文件
  Imageset.txt 会存放所有图集对应的 .plist 文件 

  将 Imageset.txt 放在 项目目录 Resource 文件夹中，
  .plist 和 .png 放在 项目目录 Resource/Imagesetfile 中


  编辑UI时会用到图集中的散图，需要将图集中的散图放在 Texture/Imagesetfile 目录下，（随便创建一个文件夹放小图就可以在 CocosBuilder 中使用）,为了规范将所有新加的图集放到 Texture/Imagesetfile下，每一个图集单独创建一个图集对应的文件名。

注意：由于以前资源目录放置的不规范，导致修改/查找不方便，不便于维护，以后新加入资源必须放在 Texture 文件夹下 和 游戏项目中 Resources 下目录对应，
  
