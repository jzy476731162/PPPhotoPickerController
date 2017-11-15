# PPPhotoPickerController
This component can only pick photo via camera or Album.It can use your custom Theme Color and hint text show style.

这款项目可以从相机或相册中选取照片.你可以自定义主题颜色以及提示的显示方式.
 <br />
 <br />

Notice:
If this component's function is enough to use and you want to custom theme or others.Modify the properties value of `[PhotoPickerConfig defaultConfig]`

注意:如果功能足够并且您需要自定义主题颜色或其他内容,可以去修改 `[PhotoPickerConfig defaultConfig]`的属性

 <br />
 <br />

This demo use DZNEmptyDataSet to show Disable-Auth or no-photos view in Album,you can remove `PPAlbum`'s DZNDelegate to custom your own no-data-view

这个Demo使用`DZNEmptyDataSet `来展示未授权相册权限或相册无图,你可以移除PPAlbum的DZNDelegate来自定义您的view

 <br />
 <br />

Let's have a look at `PhotoPickerConfig.h`.It has two block property named `messageBlock` and `albumFilter`.

```
messageBlock: ^(void)(NSString *info, UIViewController *showView, alertContinueBlock block)

@info 
means the error info you need show by your components.

@showView 
is for components like showinView:...

@block 
if this block != nil.It means that this should shown as an alert, the info will be :
"you have photos X,X,X haven't prefetched now ,would you continue to commit the photos?" 
and when user tap sure, you should invoke `block()` to indicate the PhotoPicker to continue.

If this Block == nil.You can show it on a Hud or other weak hint components.

```

```
albumFilter:^(NSMutableArray *)(void)
This components defaults' album are 
`PHAssetCollectionSubtypeSmartAlbumUserLibrary`
`PHAssetCollectionSubtypeSmartAlbumFavorites`
`PHAssetCollectionSubtypeSmartAlbumGeneric`
`PHAssetCollectionSubtypeSmartAlbumPanoramas`
`PHAssetCollectionSubtypeAny`
and user's created albums.

If you want to custom albums ,just set this block return the albums you want to show.Ex: `PPAlbumEntity.m` line:61
```


 <br />
 <br />
 
Don't forget to set `Privacy - Camera Usage Description` and `Privacy - Photo Library Usage Description` in info.plist.

不要忘记在info.plist中设置`Privacy - Camera Usage Description`和`Privacy - Photo Library Usage Description`
