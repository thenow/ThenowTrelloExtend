###
// ==UserScript==
// @name         Trello - Show Card Count
// @name:zh-CN   Trello - 显示卡片数量
// @namespace    http://ejiasoft.com/
// @homepageurl  https://greasyfork.org/scripts/25627-trello-show-card-count
// @version      1.2.4
// @description  Show card count at the end of board title
// @description:zh-CN 在列表头部显示卡片数量
// @author       thenow
// @match        http*://*trello.com
// @match        http*://*trello.com/*
// @grant        none
// ==/UserScript==
###

curUrl = window.location.href # 当前页面地址

pageRegex = # 需要用到的正则表达式
    CardLimit:/\[\d+\]/   # 卡片数量限制
    Category : /{.+}/     # 分类
    User     : /`.+`/     # 使用者
    CardCount: /^\d+/     # 当前卡片数量
    Number   : /\d+/      # 通用取数字
    CardNum  : /^#\d+/    # 卡片编号
    HomePage : /com[\/]$/ # 首页

listCardFormat = (objCard) -> # 卡片格式化
    cardTitle   = objCard.find('a.list-card-title').text()
    cardNum     = pageRegex.cardNum.exec(cardTitle)[0]
    spanCardNum = $ "<span class=\"card-short-id\">#{cardnum}</span>"

listTitleFormat = (objList) -> # 列表标题格式化
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

listFormatInit = ->
    $('div.list').each ->
        listTitleFormat $(this)
        $(this).find('div.list-card').each ->
            listCardFormat $(this)

imgSwitch_click = -> # 添加图片显示开关
    imgSwitch = $ '<a class="board-header-btn board-header-btn-org-name board-header-btn-without-icon"><span class="board-header-btn-text">隐藏/显示图片</span></a>' # 按钮对象
    $('div.board-header').append imgSwitch # 添加按钮
    imgSwitch.click ->
        $('div.list-card-cover').slideToggle()

init = ->
    loadFinish = false
    initTimer = setTimeout (->
        clearTimeout initTimer if loadFinish
        loadFinish = $('p.list-header-num-cards').length > 0
        if loadFinish
            $('p.list-header-num-cards').show() # 显示卡片数量
            $('span.card-short-id').show() # 显示卡片编号
            listFormatInit()
            imgSwitch_click()
    ),1000

$ ->
    init()
    $('#boards-drawer').on 'click','.js-open-board',->
        init()
    $('#content').on 'click','.js-react-root a.board-title',->
        init()