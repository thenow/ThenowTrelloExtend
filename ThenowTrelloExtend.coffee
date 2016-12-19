###
// ==UserScript==
// @name         Trello - Thenow Trello Extend
// @namespace    http://ejiasoft.com/
// @version      1.1
// @description  Extend trello.com
// @description:zh-CN 扩展trello.com看板的功能
// @homepageurl  https://github.com/thenow/ThenowTrelloExtend
// @author       thenow
// @run-at       document-end
// @license      MIT license
// @match        http*://*trello.com
// @match        http*://*trello.com/*
// @grant        none
// ==/UserScript==
###

curUrl = window.location.href # 当前页面地址

pageRegex = # 需要用到的正则表达式
    CardLimit:/\[\d+\]/   # 卡片数量限制
    Category : /{.+}/g     # 分类
    User     : /`\S+`/g     # 使用者
    CardCount: /^\d+/     # 当前卡片数量
    Number   : /\d+/      # 通用取数字
    CardNum  : /^#\d+/    # 卡片编号
    HomePage : /com[\/]$/ # 首页

listCardFormat = (objCard) -> # 卡片格式化
    listCardTitle = objCard.find('a.list-card-title')
    cardTitle = listCardTitle.html() # 获取卡片标题
    cardUserArray = cardTitle.match pageRegex.User
    return if cardUserArray == null
    for cardUser in cardUserArray
        cardTitle = cardTitle.replace cardUser,''
        trueUser = cardUser.replace /`/g,''
        cardTitle += "<code>#{trueUser}</code>"
    listCardTitle.html cardTitle

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

imgSwitch_click = -> # 添加图片显示开关
    return if $('#btnImgSwitch').length > 0
    imgSwitch = $ '<a id="btnImgSwitch" class="board-header-btn board-header-btn-org-name board-header-btn-without-icon"><span class="board-header-btn-text">隐藏/显示图片</span></a>' # 按钮对象
    $('div.board-header').append imgSwitch # 添加按钮
    imgSwitch.click ->
        $('div.list-card-cover').slideToggle()

showCardNum = -> # 显示卡片编号
    $('span.card-short-id').each ->
        curCardNum = $.trim $(this).text()
        $(this).text(curCardNum+' ').show()

init = ->
    $('p.list-header-num-cards').show() # 显示卡片数量
    showCardNum()
    listFormatInit()
    imgSwitch_click()

$ ->
    setInterval (->
        init()
    ),1000