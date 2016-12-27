// Generated by CoffeeScript 1.12.2

/*
// ==UserScript==
// @name              Trello - Thenow Trello Extend
// @namespace         http://ejiasoft.com/
// @version           1.1.6.1
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
 */

(function() {
  var addBgBtn, addBoardBtn, addImgSwitchBtn, addMemberToggleBtn, boardId, boardInit, btnClass, btnTextClass, cardLabelCss, curUrl, listCardFormat, listFormatInit, listTitleFormat, pageRegex;

  pageRegex = {
    CardLimit: /\[\d+\]/,
    Category: /\{.+\}/g,
    User: /`\S+`/g,
    CardCount: /^\d+/,
    Number: /\d+/,
    CardNum: /^#\d+/,
    HomePage: /com[\/]$/,
    BoardId: /\/b\/.{8}\/-$/
  };

  curUrl = window.location.href;

  boardId = pageRegex.BoardId.exec(curUrl);

  cardLabelCss = "<style type=\"text/css\">\n    .list-card-labels .card-label {\n        font-weight: normal;\n        font-size: 10px;\n        height: 12px !important;\n        line-height: 10px !important;\n        padding: 0 3px;\n        margin: 0 3px 0 0;\n        text-shadow: none;\n        width: auto;\n        max-width: 50px;\n    }\n    .card-short-id {\n        display: inline;\n        font-weight: bold;\n    }\n    .card-short-id:after {\n        content:\" \";\n    }\n</style>";

  listCardFormat = function(objCard) {
    var listCardTitle;
    return listCardTitle = objCard.find('div.list-card-details>a.list-card-title').each(function() {
      var cardCate, cardCategoryArray, cardTitle, cardUser, cardUserArray, curCardTitle, i, j, len, len1, results;
      curCardTitle = $(this);
      cardTitle = curCardTitle.html();
      cardUserArray = cardTitle.match(pageRegex.User);
      cardCategoryArray = cardTitle.match(pageRegex.Category);
      if (cardUserArray !== null) {
        for (i = 0, len = cardUserArray.length; i < len; i++) {
          cardUser = cardUserArray[i];
          cardTitle = cardTitle.replace(cardUser, "<code>" + (cardUser.substring(1, cardUser.length - 1)) + "</code>");
          curCardTitle.html(cardTitle);
        }
      }
      if (cardCategoryArray !== null) {
        results = [];
        for (j = 0, len1 = cardCategoryArray.length; j < len1; j++) {
          cardCate = cardCategoryArray[j];
          cardTitle = cardTitle.replace(cardCate, "<code style=\"color:#0f9598\">" + (cardCate.substring(1, cardCate.length - 1)) + "</code>");
          results.push(curCardTitle.html(cardTitle));
        }
        return results;
      }
    });
  };

  listTitleFormat = function(objList) {
    var cardCount, cardLimit, cardLimitInfo, curCardCountP, curListHeader, curListTitle;
    curListHeader = objList.find('div.list-header');
    curListTitle = curListHeader.find('textarea.list-header-name').val();
    cardLimitInfo = pageRegex.CardLimit.exec(curListTitle);
    if (cardLimitInfo === null) {
      return false;
    }
    curCardCountP = curListHeader.find('p.list-header-num-cards');
    cardCount = pageRegex.CardCount.exec(curCardCountP.text())[0];
    cardLimit = pageRegex.Number.exec(cardLimitInfo[0])[0];
    if (cardCount > cardLimit) {
      return objList.css('background', '#903');
    } else if (cardCount === cardLimit) {
      return objList.css('background', '#c93');
    } else {
      return objList.css('background', '#e2e4e6');
    }
  };

  listFormatInit = function() {
    return $('div.list').each(function() {
      listTitleFormat($(this));
      return $(this).find('div.list-card').each(function() {
        return listCardFormat($(this));
      });
    });
  };

  btnClass = 'board-header-btn board-header-btn-org-name board-header-btn-without-icon';

  btnTextClass = 'board-header-btn-text';

  addBoardBtn = function(id, text, eventAction, eventName) {
    var newBtn;
    if (eventName == null) {
      eventName = 'click';
    }
    if ($("#" + id).length > 0) {
      return $("#" + id);
    }
    newBtn = $("<a id=\"" + id + "\" class=\"" + btnClass + "\"><span class=\"" + btnTextClass + "\">" + text + "</span></a>");
    $('div.board-header').append(newBtn);
    if (eventAction !== null) {
      newBtn.bind(eventName, eventAction);
    }
    return newBtn;
  };

  addImgSwitchBtn = function() {
    return addBoardBtn('btnImgSwitch', '隐藏/显示图片', function() {
      return $('div.list-card-cover').slideToggle();
    });
  };

  addBgBtn = function() {
    return addBoardBtn('setBgBtn', '设置背景图片', function() {
      var newBgUrl, oldBgUrl;
      oldBgUrl = localStorage[boardId[0]];
      newBgUrl = prompt('请输入背景图片地址', oldBgUrl);
      if (newBgUrl === oldBgUrl) {
        return;
      }
      if (newBgUrl === null || newBgUrl === '') {
        localStorage.removeItem(boardId[0]);
        $('body').css('background-image', '');
        return;
      }
      return localStorage[boardId[0]] = newBgUrl;
    });
  };

  addMemberToggleBtn = function() {
    return addBoardBtn('memberSwitchBtn', '隐藏/显示成员', function() {
      return $('div.list-card-members').slideToggle();
    });
  };

  boardInit = function() {
    var bgUrl, localBgUrl;
    if (pageRegex.HomePage.exec(curUrl) !== null) {
      return;
    }
    bgUrl = $('body').css('background-image');
    localBgUrl = localStorage[boardId[0]];
    if (localBgUrl !== void 0 && bgUrl !== localBgUrl) {
      $('body').css('background-image', "url(\"" + localBgUrl + "\")");
    }
    $('p.list-header-num-cards').show();
    listFormatInit();
    addImgSwitchBtn();
    addBgBtn();
    return addMemberToggleBtn();
  };

  $(function() {
    $('head').append(cardLabelCss);
    return setInterval((function() {
      curUrl = window.location.href;
      boardId = pageRegex.BoardId.exec(curUrl);
      return boardInit();
    }), 1000);
  });

}).call(this);
