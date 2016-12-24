###
// ==UserScript==
// @name              Trello - Thenow Trello Extend
// @namespace         http://ejiasoft.com/
// @version           1.1.6
// @description       Extend trello.com
// @description:zh-CN 扩展trello.com看板的功能
// @homepageurl       https://github.com/thenow/ThenowTrelloExtend
// @author            thenow
// @run-at            document-end
// @license           MIT license
// @match             http*://*trello.com
// @match             http*://*trello.com/*
// @grant             none
// ==/UserScript==
###

pageRegex = # 需要用到的正则表达式
    CardLimit:/\[\d+\]/   # 卡片数量限制
    Category : /\{.+\}/g  # 分类
    User     : /`\S+`/g   # 使用者
    CardCount: /^\d+/     # 当前卡片数量
    Number   : /\d+/      # 通用取数字
    CardNum  : /^#\d+/    # 卡片编号
    HomePage : /com[\/]$/ # 首页
    BoardId  : /\/b\/.{8}\/-$/ # 看板页面

curUrl = window.location.href # 当前页面地址
boardId = pageRegex.BoardId.exec curUrl # 当前看板ID

cardLabelCss = """
<style type="text/css">
    .list-card-labels .card-label {
        font-weight: normal;
        font-size: 10px;
        height: 12px !important;
        line-height: 10px !important;
        padding: 0 3px;
        margin: 0 3px 0 0;
        text-shadow: none;
        width: auto;
        max-width: 50px;
    }
    .card-short-id {
        display: inline;
        font-weight: bold;
    }
    .card-short-id:after {
        content:" ";
    }
</style>"""

listCardFormat = (objCard) -> # 卡片格式化
    listCardTitle = objCard.find('div.list-card-details>a.list-card-title').each ->
        curCardTitle = $ this
        cardTitle = curCardTitle.html() # 获取卡片标题HTML内容
        cardUserArray = cardTitle.match pageRegex.User # 匹配相关人员标记
        cardCategoryArray = cardTitle.match pageRegex.Category # 匹配分类标记
        if cardUserArray != null
            for cardUser in cardUserArray
                cardTitle = cardTitle.replace cardUser,"<code>#{cardUser.substring 1,cardUser.length-1}</code>"
                curCardTitle.html cardTitle
        if cardCategoryArray != null
            for cardCate in cardCategoryArray 
                cardTitle = cardTitle.replace cardCate,"<code style=\"color:#0f9598\">#{cardCate.substring 1,cardCate.length-1}</code>"
                curCardTitle.html cardTitle

listTitleFormat = (objList) -> # 在制品限制功能
    curListHeader = objList.find 'div.list-header' # 当前列表对象
    curListTitle  = curListHeader.find('textarea.list-header-name').val() # 当前列表名称
    cardLimitInfo = pageRegex.CardLimit.exec curListTitle
    return false if cardLimitInfo == null
    curCardCountP = curListHeader.find 'p.list-header-num-cards'
    cardCount = pageRegex.CardCount.exec(curCardCountP.text())[0]
    cardLimit = pageRegex.Number.exec(cardLimitInfo[0])[0]
    if cardCount > cardLimit
        objList.css 'background','#903'
    else if cardCount == cardLimit
        objList.css 'background','#c93'
    else
        objList.css 'background','#e2e4e6'

listFormatInit = ->
    $('div.list').each ->
        listTitleFormat $(this)
        $(this).find('div.list-card').each ->
            listCardFormat $(this)
            
btnClass = 'board-header-btn board-header-btn-org-name board-header-btn-without-icon'
btnTextClass = 'board-header-btn-text'
addBoardBtn = (id, text, eventAction, eventName='click')-> # 添加按钮
    return $ "##{id}" if $("##{id}").length >0
    newBtn = $ "<a id=\"#{id}\" class=\"#{btnClass}\"><span class=\"#{btnTextClass}\">#{text}</span></a>" # 按钮对象
    $('div.board-header').append newBtn # 添加按钮
    newBtn.bind eventName,eventAction if eventAction != null # 绑定事件
    return newBtn # 返回按钮对象

addImgSwitchBtn = -> # 添加图片显示开关
    addBoardBtn 'btnImgSwitch','隐藏/显示图片',->
        $('div.list-card-cover').slideToggle()

addBgBtn = -> # 添加修改背景按钮
    addBoardBtn 'setBgBtn','设置背景图片',->
        oldBgUrl = localStorage[boardId[0]]
        newBgUrl = prompt '请输入背景图片地址',oldBgUrl
        return if newBgUrl == oldBgUrl
        if newBgUrl == null or newBgUrl == ''
            localStorage.removeItem boardId[0]
            return
        localStorage[boardId[0]] = newBgUrl

addMemberToggleBtn = -> # 添加成员显示开关
    addBoardBtn 'memberSwitchBtn','隐藏/显示成员',->
        $('div.list-card-members').slideToggle()

boardInit = ->
    return if pageRegex.HomePage.exec(curUrl) != null # 首页不执行
    bgUrl = $('body').css 'background-image'
    localBgUrl = localStorage[boardId[0]]
    if localBgUrl != undefined and bgUrl != localBgUrl
        $('body').css 'background-image',"url(\"#{localBgUrl}\")" 
    $('p.list-header-num-cards').show() # 显示卡片数量
    listFormatInit()
    addImgSwitchBtn()
    addBgBtn()
    addMemberToggleBtn()

$ ->
    $('head').append cardLabelCss
    setInterval (->
        curUrl = window.location.href # 当前页面地址
        boardId = pageRegex.BoardId.exec curUrl # 当前看板ID
        boardInit()
    ),1000