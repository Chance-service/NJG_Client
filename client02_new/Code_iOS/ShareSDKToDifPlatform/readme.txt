PS：
  为了保持iOS项目工程的Target的维护及操作统一性，使用该Target进行开发是需将次Target上添加新的工程或者非com4loves的SDK时，
  请注明添加过的操作如下：

注：
   由于本工程Target每一个.a的静态文件都是相互独立的，所有开发者需要特别注意，在使用duplicate时，建议使用ShareSDKToGameCenter.a进行操作，
   修改之后修改对应文件的名字，还需在Build Setting中将Pacaging中修改对应的Product Name 注意：命名规则是ShareSDKToXXX.a，必须以ShareSDKTo为前缀，
   即    ShareSDKTo + 加功能名.a  形式；
   PS： 每个单独的.a 或者每个新建的文件夹中的 所有功能都是一个单独而可以提供给 所有平台使用的SDK才可在此工程中操作，只针对单个平台的SDK接入切勿使用本工程；


  1.再次Target操作是需先在ShareSDKToDifPlatform个根工程同一级目录下新建文件下，之后不同SDK<非针对单个平台的SDK>，对应的SDK等使用到的文件都必须放入改文件夹中；
  2.新建文件家目录与ShareSDKToDifPlatform.xcodeproj属于同级目录，即所有新建文件夹要和readme.txt也是同一级；
  3.强调由于是新的SDK的.a静态文件一般都是 duplicate出来的所有需要先清掉旧的文件在操作，具体步骤如下：

        A.找到Build Phases;
        B.分别删除 旧的.a中 Compile Sources中的.m和.mm等文件，及 Copy Files中的.h头文件；
        C.此时可以进行第4步操作，如果第4步操作后再Copy Files中没有出现唯一的<提供给其他Target工程使用的唯一.h头文件>，则需根据情况手动添加；


  4.之后可选定工程右键添加该文件需以group非copy方式导入进来；选定所需的.a文件作为所有者；