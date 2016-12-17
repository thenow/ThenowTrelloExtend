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

var curUrl = window.location.href;

var pageRegex = {
    CardLimit : /\[\d+\]/, // 卡片数量限制
    Categry : /{.+}/, // 分类
    User : /`.+`/, // 使用者
    CardCount : /^\d+/, // 当前卡片数量
    Number : /\d+/, // 通用取数字
    CardNum : /^#\d+/ // 卡片编号
};

var listCardFormat = function(objCard) { // 卡片格式化
    var cardTitle = objCard.find('a.list-card-title').text();
    var cardNum = pageRegex.CardNum.exec(cardTitle)[0];
    var spanCardNum = $('<span class="card-short-id">'+cardNum+'</span>');
};

var listTitleFormat = function(objList) { // 列表标题格式化
    var curListHeader = objList.find('div.list-header'); // 当前列表对象
    var curListTitle = curListHeader.find('textarea.list-header-name').val(); // 当前列表名称
    var cardLimitInfo = pageRegex.CardLimit.exec(curListTitle);
    if(cardLimitInfo === null) { return false; }
    var curCardCountP = curListHeader.find('p.list-header-num-cards');
    var cardCount = pageRegex.CardCount.exec(curCardCountP.text())[0];
    var cardLimit = pageRegex.Number.exec(cardLimitInfo[0])[0];
    if(cardCount > cardLimit) {
        objList.css('background','#903');
    } else if(cardCount == cardLimit) {
        objList.css('background','#c93');
    }
};

var listFormatInit = function() {
    $('div.list').each(function(){
        listTitleFormat($(this));
        $(this).find('div.list-card').each(function() {
            listCardFormat($(this));
        });
    });
};

var imgSwitch_click = function(){ // 添加图片显示开关功能
    var imgSwitch = $('<a class="board-header-btn board-header-btn-org-name board-header-btn-without-icon"><span class="board-header-btn-text">隐藏/显示图片</span></a>'); // 按钮对象
    $('div.board-header').append(imgSwitch); // 添加按钮
    imgSwitch.click(function(){
        $('div.list-card-cover').slideToggle();
    });
};

var init = function() {
    var loadFinish = false;
    var initTimer = setTimeout(function(){
        if(loadFinish) { clearTimeout(initTimer); }
        loadFinish = $('p.list-header-num-cards').length > 0;
        if(loadFinish) {
            $('p.list-header-num-cards').show(); // 显示卡片数量
            $('span.card-short-id').show(); // 显示卡片编号
            listFormatInit();
            imgSwitch_click();
        }
    }, 1000);
};

$(function(){
    init();
    $("#boards-drawer").on("click",".js-open-board",function(){ // 看板栏点击事件
        init();
    });
    $("#content").on("click",".js-react-root a.board-tile",function(){ // 首页内容点击
        init();
    });
});