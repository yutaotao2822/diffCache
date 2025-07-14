# diff_cache

Comparing and caching server files，By comparing the ETag of the server file

## Getting Started

1.初始化
    请放在main.dart
    DiffCache.init();

2.使用
    DiffCache dc = DiffCache();
    
（1）添加缓存的文件地址和名称
    await dc.tapAdd("缓存在本地的文件名称（可以用_,不建议使用其他的特殊字符）","文件地址");
    
（2）通过名称更新某一个文件
    await dc.update((List<String> success, List<String> fail, List<String> jump){
        // success 下载成功的文件名称列表
        // fail 下载失败的文件名称列表        
        // jump 服务器文件没有更改，跳过下载的文件名称列表
    }, fileName: "文件名称");

（3）通过名称强制更新文件
    await dc.updateMust((List<String> success, List<String> fail, List<String> jump){
        // success 下载成功的文件名称列表
        // fail 下载失败的文件名称列表        
        // jump 服务器文件没有更改，跳过下载的文件名称列表
    }, fileName: "文件名称");

（4）更新所有的文件
    await dc.update((List<String> success, List<String> fail, List<String> jump){
        // success 下载成功的文件名称列表
        // fail 下载失败的文件名称列表        
        // jump 服务器文件没有更改，跳过下载的文件名称列表
    });

（4）强制更新所有的文件
    await dc.updateMust((List<String> success, List<String> fail, List<String> jump){
        // success 下载成功的文件名称列表
        // fail 下载失败的文件名称列表        
        // jump 服务器文件没有更改，跳过下载的文件名称列表
    });

（5）通过名称读取缓存的文件
    String fileContent = await dc.read("文件名称")

（6）删除某一个文件
    dc.remove("文件名称");

（7）清空所有的文件
    dc.clear();