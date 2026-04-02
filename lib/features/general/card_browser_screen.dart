import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:student_study/app/theme/colors.dart';
import 'package:student_study/features/general/widgets/knowledge_card.dart';

/// 百科卡片浏览页面的分类数据，用于确定展示的示例内容。
class _CategoryContent {
  const _CategoryContent({
    required this.icon,
    required this.color,
    required this.cards,
  });

  final IconData icon;
  final Color color;
  final List<KnowledgeCardData> cards;
}

/// 为各分类预生成的示例知识卡片内容。
final Map<String, _CategoryContent> _categoryContents = {
  'astronomy_geography': _CategoryContent(
    icon: Icons.public,
    color: AppColors.primary,
    cards: [
      KnowledgeCardData(
        title: '太阳系的八大行星',
        summary: '太阳系由八颗行星组成，从离太阳最近到最远依次为：水星、金星、地球、火星、木星、土星、天王星和海王星。每颗行星都有独特的特征。',
        categoryIcon: Icons.public,
        categoryColor: AppColors.primary,
        detailSections: {
          '类地行星': '水星、金星、地球和火星是类地行星，它们体积较小，主要由岩石和金属构成，表面坚硬。',
          '类木行星': '木星、土星、天王星和海王星是类木行星，它们体积巨大，主要由气体组成，没有固体表面。',
          '矮行星': '冥王星在2006年被重新归类为矮行星，不再属于八大行星之列。',
        },
        funFacts: ['木星能装下1300个地球', '土星密度比水还小', '金星自转方向相反'],
      ),
      KnowledgeCardData(
        title: '地球的构造',
        summary: '地球由地壳、地幔和地核三大部分组成。地壳是我们生活的表面层，地幔是中间层，地核则在最深处，温度高达5000度以上。',
        categoryIcon: Icons.public,
        categoryColor: AppColors.primary,
        detailSections: {
          '地壳': '地壳平均厚度约35公里，是地球最薄的一层，分为大陆地壳和海洋地壳。',
          '地幔': '地幔厚度约2900公里，占地球体积的82%，由半流体的岩浆物质组成。',
          '地核': '地核分为外核（液态）和内核（固态），主要由铁和镍组成。',
        },
        funFacts: ['地球年龄约45.4亿年', '地表71%被水覆盖', '最深处在马里亚纳海沟'],
      ),
      KnowledgeCardData(
        title: '四季的形成',
        summary: '四季的产生是因为地球的自转轴与公转轨道平面之间有23.5度的倾角。当北半球朝向太阳时是夏季，远离太阳时是冬季。',
        categoryIcon: Icons.public,
        categoryColor: AppColors.primary,
        detailSections: {
          '夏至与冬至': '夏至日（6月21日左右）北半球白昼最长，冬至日（12月22日左右）白昼最短。',
          '春分与秋分': '春分和秋分时，全球昼夜几乎等长，各约12小时。',
        },
        funFacts: ['南北半球季节相反', '赤道附近没有四季', '地球一年绕太阳一圈'],
      ),
      KnowledgeCardData(
        title: '大洲与大洋',
        summary: '地球上有七大洲：亚洲、非洲、北美洲、南美洲、南极洲、欧洲和大洋洲；四大洋：太平洋、大西洋、印度洋和北冰洋。',
        categoryIcon: Icons.public,
        categoryColor: AppColors.primary,
        detailSections: {
          '最大的洲': '亚洲是面积最大的洲，约4400万平方公里，占陆地面积的三分之一。',
          '最大的洋': '太平洋是面积最大的海洋，面积约1.65亿平方公里，比所有陆地面积加起来还大。',
        },
        funFacts: ['亚洲人口最多', '南极洲最冷', '太平洋最深处超万米'],
      ),
      KnowledgeCardData(
        title: '月亮的奥秘',
        summary: '月球是地球唯一的天然卫星，距离地球约38.4万公里。月球没有大气层，表面布满环形山，它影响着地球的潮汐。',
        categoryIcon: Icons.public,
        categoryColor: AppColors.primary,
        detailSections: {
          '月相变化': '月球绕地球公转一周约29.5天，形成新月、上弦月、满月、下弦月等月相变化。',
          '潮汐作用': '月球的引力使海水产生潮汐现象，每天涨潮退潮各两次。',
        },
        funFacts: ['月球正在远离地球', '月球上没有声音', '只有12人登上过月球'],
      ),
      KnowledgeCardData(
        title: '火山与地震',
        summary: '火山和地震是地球内部能量释放的表现。火山喷发时岩浆从地底涌出，地震则是地壳板块运动引起的振动。',
        categoryIcon: Icons.public,
        categoryColor: AppColors.primary,
        detailSections: {
          '板块构造': '地球表面由十几个大大小小的板块组成，板块的碰撞和分离是火山、地震的主要原因。',
          '环太平洋火山带': '全球约75%的活火山和90%的地震发生在环太平洋火山带上。',
        },
        funFacts: ['全球每天发生数千次地震', '最高的火山在火星上', '海底也有火山'],
      ),
      KnowledgeCardData(
        title: '天气与气候',
        summary: '天气是短时间内大气的状态，气候是一个地区长期的天气平均状况。风、雨、雪、雾等都是常见的天气现象。',
        categoryIcon: Icons.public,
        categoryColor: AppColors.primary,
        detailSections: {
          '水循环': '太阳加热海水蒸发形成云，云中水汽凝结降雨，雨水汇入河流回到大海，形成水循环。',
          '气候带': '地球从赤道到两极分为热带、温带和寒带，各有不同的气候特征。',
        },
        funFacts: ['闪电温度比太阳表面还高', '最大的雨滴约1厘米', '南极是最干燥的大陆'],
      ),
      KnowledgeCardData(
        title: '星座与导航',
        summary: '古人通过观察星空划分了88个星座。北极星位于北方天空，千百年来一直被用作导航的重要参考。',
        categoryIcon: Icons.public,
        categoryColor: AppColors.primary,
        detailSections: {
          '黄道十二宫': '太阳在一年中经过的12个星座被称为黄道十二宫，包括白羊座、金牛座等。',
          '北斗七星': '北斗七星是大熊座的一部分，其斗柄指向可以判断季节。',
        },
        funFacts: ['肉眼可见约6000颗星', '最近的恒星距4.2光年', '银河系有千亿颗恒星'],
      ),
    ],
  ),
  'history': _CategoryContent(
    icon: Icons.history_edu,
    color: const Color(0xFF6D4C41),
    cards: [
      KnowledgeCardData(
        title: '四大文明古国',
        summary: '古埃及、古巴比伦、古印度和古中国是世界四大文明古国。它们分别诞生于尼罗河、两河流域、印度河和黄河流域。',
        categoryIcon: Icons.history_edu,
        categoryColor: const Color(0xFF6D4C41),
        detailSections: {
          '古埃及': '以金字塔和法老闻名，创造了象形文字，文明延续约3000年。',
          '古中国': '是唯一延续至今的古文明，创造了甲骨文，发明了造纸术等四大发明。',
        },
        funFacts: ['金字塔建于4500年前', '中国文明从未中断', '古巴比伦发明了60进制'],
      ),
      KnowledgeCardData(
        title: '丝绸之路',
        summary: '丝绸之路是古代连接中国与地中海地区的贸易路线，以中国出产的丝绸命名。它促进了东西方文化和商品的交流。',
        categoryIcon: Icons.history_edu,
        categoryColor: const Color(0xFF6D4C41),
        detailSections: {
          '陆上丝路': '从长安出发，经河西走廊、中亚到达地中海沿岸，全长约7000公里。',
          '海上丝路': '从泉州、广州等港口出发，经南海、印度洋到达非洲东海岸。',
        },
        funFacts: ['张骞是丝路开拓者', '传播了造纸和火药', '郑和七下西洋'],
      ),
      KnowledgeCardData(
        title: '中国古代四大发明',
        summary: '造纸术、印刷术、火药和指南针是中国古代的四大发明，它们对世界文明发展产生了深远影响。',
        categoryIcon: Icons.history_edu,
        categoryColor: const Color(0xFF6D4C41),
        detailSections: {
          '造纸术': '东汉蔡伦改进造纸工艺，用树皮、破布等原料制造出轻便的纸张。',
          '指南针': '最早的指南针是司南，利用天然磁石的磁性指示方向。',
        },
        funFacts: ['活字印刷比西方早400年', '火药最初用于炼丹', '指南针改变了航海'],
      ),
      KnowledgeCardData(
        title: '恐龙时代',
        summary: '恐龙在约2.3亿年前出现，统治地球长达1.6亿年。约6600万年前因小行星撞击地球而灭绝。',
        categoryIcon: Icons.history_edu,
        categoryColor: const Color(0xFF6D4C41),
        detailSections: {
          '恐龙种类': '恐龙分为蜥臀目和鸟臀目两大类，包括霸王龙、三角龙、梁龙等著名种类。',
          '灭绝原因': '主流理论认为一颗直径约10公里的小行星撞击了现在的墨西哥湾地区。',
        },
        funFacts: ['鸟类是恐龙的后代', '最大恐龙长达40米', '中国发现恐龙化石最多'],
      ),
      KnowledgeCardData(
        title: '古代奥运会',
        summary: '奥运会起源于公元前776年的古希腊奥林匹亚，最初是祭祀宙斯的宗教活动。现代奥运会于1896年在雅典复兴。',
        categoryIcon: Icons.history_edu,
        categoryColor: const Color(0xFF6D4C41),
        detailSections: {
          '古代项目': '古代奥运会项目包括短跑、摔跤、拳击、战车赛等，只允许男性参加。',
          '现代复兴': '法国人顾拜旦推动了现代奥运会的复兴，提出"更快、更高、更强"的口号。',
        },
        funFacts: ['古代奥运持续了1169年', '奥运五环代表五大洲', '北京举办过夏季和冬季奥运'],
      ),
      KnowledgeCardData(
        title: '万里长城',
        summary: '长城是中国古代的军事防御工程，始建于春秋战国时期，秦始皇统一后大规模修建。现存长城主要为明代修建。',
        categoryIcon: Icons.history_edu,
        categoryColor: const Color(0xFF6D4C41),
        detailSections: {
          '建造历史': '长城历经多个朝代修建，总长度超过2万公里，是世界上最长的建筑工程。',
          '建筑特点': '长城依山势而建，设有烽火台、关隘等防御设施，八达岭是最著名的段落。',
        },
        funFacts: ['长城不能从太空看到', '修建耗时2000多年', '是世界文化遗产'],
      ),
    ],
  ),
  'art': _CategoryContent(
    icon: Icons.palette,
    color: const Color(0xFFAD1457),
    cards: [
      KnowledgeCardData(
        title: '色彩的奥秘',
        summary: '颜色来自光的不同波长。红、黄、蓝是三原色，通过混合可以产生其他所有颜色。彩虹就是太阳光被水滴折射后分解成的七种颜色。',
        categoryIcon: Icons.palette,
        categoryColor: const Color(0xFFAD1457),
        detailSections: {
          '三原色': '红、黄、蓝是颜料的三原色，任意两种混合可以得到橙、绿、紫三种间色。',
          '冷暖色': '红、橙、黄是暖色，给人温暖热情的感觉；蓝、绿、紫是冷色，给人宁静清凉的感觉。',
        },
        funFacts: ['螳螂虾能看到16种颜色', '狗只能看到两种颜色', '红色最能吸引注意力'],
      ),
      KnowledgeCardData(
        title: '中国书法',
        summary: '中国书法是用毛笔书写汉字的艺术。楷书、行书、草书、隶书和篆书是主要的五种字体，每种都有独特的风格和美感。',
        categoryIcon: Icons.palette,
        categoryColor: const Color(0xFFAD1457),
        detailSections: {
          '文房四宝': '笔、墨、纸、砚是书法所需的四种工具，合称文房四宝。',
          '名家书法': '王羲之的《兰亭序》被誉为"天下第一行书"，颜真卿的楷书端庄有力。',
        },
        funFacts: ['汉字已有3000多年历史', '毛笔发明于战国时期', '书法是中国特有的艺术'],
      ),
      KnowledgeCardData(
        title: '世界著名画作',
        summary: '达芬奇的《蒙娜丽莎》、梵高的《星夜》、莫奈的《睡莲》等都是世界美术史上最重要的画作。每幅画都代表了一个艺术时代。',
        categoryIcon: Icons.palette,
        categoryColor: const Color(0xFFAD1457),
        detailSections: {
          '文艺复兴': '达芬奇、米开朗基罗和拉斐尔被称为文艺复兴三杰，他们的作品至今令人叹为观止。',
          '印象派': '莫奈、雷诺阿等画家追求光影变化，用色彩捕捉转瞬即逝的印象。',
        },
        funFacts: ['蒙娜丽莎收藏于卢浮宫', '梵高生前只卖出一幅画', '齐白石擅画虾'],
      ),
      KnowledgeCardData(
        title: '音乐与乐器',
        summary: '音乐由旋律、节奏和和声三个基本要素组成。世界各地有着丰富多彩的乐器，从中国的古琴到西方的钢琴。',
        categoryIcon: Icons.palette,
        categoryColor: const Color(0xFFAD1457),
        detailSections: {
          '中国民族乐器': '古琴、琵琶、二胡、笛子等是中国传统乐器，合称民族乐器。',
          '西方乐器分类': '西方乐器分为弦乐、管乐、打击乐和键盘乐四大类。',
        },
        funFacts: ['古琴有3000年历史', '钢琴被称为乐器之王', '全世界有1500多种乐器'],
      ),
      KnowledgeCardData(
        title: '建筑之美',
        summary: '从中国的故宫到法国的埃菲尔铁塔，世界各地的建筑展现了不同文化的审美观念和建筑技术。建筑是凝固的音乐。',
        categoryIcon: Icons.palette,
        categoryColor: const Color(0xFFAD1457),
        detailSections: {
          '中国古建筑': '故宫是世界上现存规模最大的宫殿建筑群，采用传统的木结构和对称布局。',
          '西方建筑': '从古罗马竞技场到哥特式教堂，西方建筑以石材为主，追求高大宏伟。',
        },
        funFacts: ['故宫有9999间半房间', '埃菲尔铁塔原计划拆除', '悉尼歌剧院建了16年'],
      ),
    ],
  ),
  'life_skills': _CategoryContent(
    icon: Icons.handyman,
    color: const Color(0xFF2E7D32),
    cards: [
      KnowledgeCardData(
        title: '安全用电常识',
        summary: '电是我们日常生活的好帮手，但使用不当会很危险。了解安全用电知识，保护自己和家人。',
        categoryIcon: Icons.handyman,
        categoryColor: const Color(0xFF2E7D32),
        detailSections: {
          '基本规则': '不要用湿手触摸电器和开关，不要在电线上晾衣服，不要私拉乱接电线。',
          '紧急处理': '发现有人触电，不能直接用手拉，应先切断电源或用干燥的木棍拨开电线。',
        },
        funFacts: ['人体安全电压是36伏', '雷电温度达3万度', '静电电压可达数千伏'],
      ),
      KnowledgeCardData(
        title: '健康饮食金字塔',
        summary: '合理膳食对成长发育至关重要。食物金字塔告诉我们每天应该吃多少谷物、蔬果、蛋白质和油脂。',
        categoryIcon: Icons.handyman,
        categoryColor: const Color(0xFF2E7D32),
        detailSections: {
          '五大类食物': '谷薯类提供能量，蔬菜水果提供维生素，肉蛋奶提供蛋白质，豆类和坚果补充营养。',
          '饮食建议': '每天喝够8杯水，少吃油炸和高糖食品，三餐定时定量，多吃新鲜蔬果。',
        },
        funFacts: ['人一生要吃约60吨食物', '胡萝卜富含维生素A', '牛奶富含钙质'],
      ),
      KnowledgeCardData(
        title: '交通安全知识',
        summary: '遵守交通规则是每个人的责任。红灯停、绿灯行，走路要走人行道，过马路要走斑马线。',
        categoryIcon: Icons.handyman,
        categoryColor: const Color(0xFF2E7D32),
        detailSections: {
          '行人安全': '走路时不要看手机，过马路要左右看，不要在马路上追逐打闹。',
          '乘车安全': '乘车要系好安全带，不要将头手伸出车窗，下车后要观察再通行。',
        },
        funFacts: ['第一个红绿灯在伦敦', '斑马线因颜色得名', '安全带能降低70%伤亡'],
      ),
      KnowledgeCardData(
        title: '垃圾分类',
        summary: '垃圾分类是保护环境的重要举措。可回收物、有害垃圾、厨余垃圾和其他垃圾要分别投放到对应的垃圾桶中。',
        categoryIcon: Icons.handyman,
        categoryColor: const Color(0xFF2E7D32),
        detailSections: {
          '四类垃圾': '蓝色桶放可回收物，红色桶放有害垃圾，绿色桶放厨余垃圾，灰色桶放其他垃圾。',
          '回收利用': '废纸可以再生纸张，塑料瓶可以制成衣服纤维，玻璃可以反复回收利用。',
        },
        funFacts: ['一个塑料袋需200年降解', '回收1吨纸可救17棵树', '中国日产垃圾超百万吨'],
      ),
      KnowledgeCardData(
        title: '时间管理',
        summary: '合理安排时间能让学习和生活更加高效。制定计划、分清轻重缓急、劳逸结合是时间管理的关键。',
        categoryIcon: Icons.handyman,
        categoryColor: const Color(0xFF2E7D32),
        detailSections: {
          '番茄工作法': '每25分钟为一个番茄时段，专注学习后休息5分钟，每完成4个番茄时段休息15-30分钟。',
          '制定计划': '每天列出要做的事情，按重要程度排序，先做最重要的事情。',
        },
        funFacts: ['人一生有9年在排队', '早起大脑最清醒', '习惯养成需21天'],
      ),
      KnowledgeCardData(
        title: '急救基础知识',
        summary: '掌握基本的急救知识可以在紧急情况下帮助他人。止血、包扎、心肺复苏是最基本的急救技能。',
        categoryIcon: Icons.handyman,
        categoryColor: const Color(0xFF2E7D32),
        detailSections: {
          '紧急电话': '遇到紧急情况拨打120（急救）、119（火警）、110（报警），说清地址和情况。',
          '基本处理': '小伤口用清水冲洗后贴创可贴，流鼻血时低头捏住鼻翼，烫伤用冷水冲15分钟。',
        },
        funFacts: ['CPR可挽救心脏骤停', '海姆立克法可救窒息', '人体有206块骨头'],
      ),
      KnowledgeCardData(
        title: '节约用水',
        summary: '地球上可供饮用的淡水不到总水量的1%。节约用水是每个人应尽的责任，从日常小事做起就能积少成多。',
        categoryIcon: Icons.handyman,
        categoryColor: const Color(0xFF2E7D32),
        detailSections: {
          '节水方法': '刷牙时关掉水龙头，洗澡时间控制在10分钟内，用洗菜水浇花。',
          '水的重要性': '人体约70%由水组成，人可以一周不吃饭但不能三天不喝水。',
        },
        funFacts: ['一个漏水龙头年浪费7吨', '全球11亿人缺乏干净水', '地球97%是咸水'],
      ),
    ],
  ),
};

/// 百科卡片浏览页面。
///
/// 使用 PageView 实现左右滑动浏览知识卡片，底部显示页面指示器和当前索引。
class CardBrowserScreen extends ConsumerStatefulWidget {
  const CardBrowserScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  /// 分类唯一标识符。
  final String categoryId;

  /// 分类显示名称。
  final String categoryName;

  @override
  ConsumerState<CardBrowserScreen> createState() => _CardBrowserScreenState();
}

class _CardBrowserScreenState extends ConsumerState<CardBrowserScreen> {
  /// 当前页码控制器。
  late final PageController _pageController;

  /// 当前显示的页面索引。
  int _currentPage = 0;

  /// 当前分类的卡片列表。
  List<KnowledgeCardData> _cards = const [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadCards();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// 加载当前分类的知识卡片数据。
  void _loadCards() {
    final content = _categoryContents[widget.categoryId];
    if (content != null) {
      setState(() {
        _cards = content.cards;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = _categoryContents[widget.categoryId];
    final categoryColor = content?.color ?? AppColors.general;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _cards.isEmpty
          ? Center(
              child: Text(
                '暂无卡片内容',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          : Column(
              children: [
                // 卡片翻页区域
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _cards.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return KnowledgeCard(data: _cards[index]);
                    },
                  ),
                ),

                // 底部页面指示器和索引
                _buildPageIndicator(theme, categoryColor),
              ],
            ),
    );
  }

  /// 构建底部页面指示器和索引显示。
  Widget _buildPageIndicator(ThemeData theme, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          // 指示点
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_cards.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? activeColor
                      : activeColor.withValues(alpha:0.25),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),

          // 页码文本
          Text(
            '${_currentPage + 1}/${_cards.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
