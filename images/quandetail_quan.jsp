<%@ page language="java" import="java.util.*" pageEncoding="utf-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<jsp:include page="header.jsp"/>
<title>卡券详情</title>
<head>
    <script type="application/javascript" src="js/iscroll.js"></script>
    <link rel="stylesheet" type="text/css" href="css/scrollbar.css">
    <script type="text/javascript">
        var reqpath = '${CONTEXT_PATH}';
        var myScroll,
                pullDownEl, pullDownOffset,
                pullUpEl, pullUpOffset,
                generatedCount = 0;
        var page=1;
        var totalPage="${totalPage}";
        /**
         * 下拉刷新 （自定义实现此方法）
         * myScroll.refresh();		// 数据加载完成后，调用界面更新方法
         */
        function pullDownAction () {
        }

        /**
         * 滚动翻页 （自定义实现此方法）
         * myScroll.refresh();		// 数据加载完成后，调用界面更新方法
         */
        function pullUpAction () {
            setTimeout(function () {	// <-- Simulate network congestion, remove setTimeout from production!
                getdata();
                myScroll.refresh();		//数据加载完成后，调用界面更新方法   Remember to refresh when contents are loaded (ie: on ajax completion)
            }, 1000);	// <-- Simulate network congestion, remove setTimeout from production!
        }

        /**
         * 初始化iScroll控件
         */
        function loaded() {
            pullDownEl = document.getElementById('pullDown');
            pullDownOffset = pullDownEl.offsetHeight;
            pullUpEl = document.getElementById('pullUp');
            pullUpOffset = pullUpEl.offsetHeight;

            myScroll = new iScroll('wrapper', {
                scrollbarClass: 'myScrollbar', /* 重要样式 */
                useTransition: false, /* 此属性不知用意，本人从true改为false */
                topOffset: pullDownOffset,
                onRefresh: function () {
                    if (pullDownEl.className.match('loading')) {
                        pullDownEl.className = '';
                        pullDownEl.querySelector('.pullDownLabel').innerHTML = '下拉刷新...';
                    } else if (pullUpEl.className.match('loading')) {
                        pullUpEl.className = '';
                        pullUpEl.querySelector('.pullUpLabel').innerHTML = '上拉加载更多...';
                    }
                },
                onScrollMove: function () {
                    if (this.y > 5 && !pullDownEl.className.match('flip')) {
                        pullDownEl.className = 'flip';
                        pullDownEl.querySelector('.pullDownLabel').innerHTML = '松手开始更新...';
                        this.minScrollY = 0;
                    } else if (this.y < 5 && pullDownEl.className.match('flip')) {
                        pullDownEl.className = '';
                        pullDownEl.querySelector('.pullDownLabel').innerHTML = '下拉刷新...';
                        this.minScrollY = -pullDownOffset;
                    } else if (this.y < (this.maxScrollY - 5) && !pullUpEl.className.match('flip')) {
                        pullUpEl.className = 'flip';
                        pullUpEl.querySelector('.pullUpLabel').innerHTML = '松手开始更新...';
                        this.maxScrollY = this.maxScrollY;
                    } else if (this.y > (this.maxScrollY + 5) && pullUpEl.className.match('flip')) {
                        pullUpEl.className = '';
                        pullUpEl.querySelector('.pullUpLabel').innerHTML = '上拉加载更多...';
                        this.maxScrollY = pullUpOffset;
                    }
                },
                onScrollEnd: function () {
                    if (pullDownEl.className.match('flip')) {
                        pullDownEl.className = 'loading';
                        pullDownEl.querySelector('.pullDownLabel').innerHTML = '加载中...';
                        pullDownAction();	// Execute custom function (ajax call?)
                    } else if (pullUpEl.className.match('flip')) {
                        pullUpEl.className = 'loading';
                        pullUpEl.querySelector('.pullUpLabel').innerHTML = '加载中...';
                        pullUpAction();	// Execute custom function (ajax call?)
                    }
                }
            });

            setTimeout(function () { document.getElementById('wrapper').style.left = '0'; }, 800);
        }

        //初始化绑定iScroll控件
        document.addEventListener('touchmove', function (e) { e.preventDefault(); }, false);
        document.addEventListener('DOMContentLoaded', loaded, false);




        function getdata(){
            if(page==totalPage)
            {
                $("#pullUp").html("已到最后一页");

                return;
            }
            $.ajax({

                type:"POST",
                url:"${CONTEXT_PATH}/quan/quandetailPage",
                data:{'page':page+1,'publicType':$("#publicType").val(),'accountType':$("#accountType").val(),'publicSource':$("#publicSource").val()},
                dataType:"json",
                success:function(data) {
                    var list = data.detailInfo;
                    var json = eval(list); //数组
                    page = parseInt(data.page);
                    totalPage=data.totalPage;
                    $.each(json, function (index, item) {

                        //循环获取数据
                        var html = "";
                        html+='<div class="la_Kjlist">';
                        html+='<a href="javascript:void(0)" onclick="gouse(\''+item.useType+'\',\''+item.cardNo+'\');"  class="la_sybtn"><span>使用</span></a>';
                        html+='<ul>';
                        html+='<li><span>有效期至</span>'+item.expireTime+'</li>';
                        if($("#publicSource").val()=="1"||$("#publicType").val()=="1"){
                            html+='<li style="color:#000"><span>可用额</span>'+item.curBalance+'</li>';
                        }
                        if($("#publicSource").val()!="1"&&$("#publicType").val()=="2"){
                            html+='<li> <span>面值</span>'+item.facePrice+'</li>';
                        }
                        html+='</ul>';
                        html+='</div>';
                        $('.wode-quan1').append(html);
                        myScroll.refresh();
                    });
                },
                error:function(data)  {
                    // console.info(msg);
                },
            });
        }
        function gouse(useType,cardNo){
            if(useType=="2"){
                alert("公众号暂不支持此类卡券，请下载资和信APP使用");
            }else{
                window.location =  reqpath+"/quan/cardqrcode?accountType="+$("#accountType").val()+"&publicType="+$("#publicType").val()+"&cardNo="+cardNo;
            }
        }
    </script>
</head>
<body>

    <div id="wrapper">
        <div id="scroller">
            <div style="overflow:auto;height:91%">
                <!--
                    正文内容区开始
                    -->
                <div class="main">
                    <div class="la_WYbox">
                        <img src="${background}" class="fl"/>
                        <div class="la_WYfont">
                            <span>${accountTypeName}</span> <br/>
                            购买张数：<b>x${quannum}</b>
                        </div>
                    </div>
                </div>

                <div id="pullDown" style="display:none">
                    <span class="pullDownIcon"></span><span class="pullDownLabel">下拉刷新...</span>
                </div>

                <div class="wode-quan1">
                    <c:forEach items="${detailInfo}" var="detailInfoData" varStatus="vs">
                        <div class="la_Kjlist">
                                <a href="javascript:void(0)" onclick="gouse('${detailInfoData.useType}','${detailInfoData.cardNo}');" class="la_sybtn"><span>使用</span></a>
                            <ul>
                                <li><span>有效期至</span> ${detailInfoData.expireTime}</li>
                                <c:if test="${publicSource==1 || publicType==1}">
                                    <li style="color:#000"> <span>可用额</span> ${detailInfoData.curBalance}</li>
                                </c:if>
                                <c:if test="${publicSource!=1 and  publicType==2}">
                                    <li> <span>面值</span> ${detailInfoData.facePrice}</li>
                                </c:if>
                            </ul>
                        </div>
                    </c:forEach>
                </div>

            <c:if test="${totalPage> 1}" >
                <div id="pullUp"  style="display:block">
            </c:if>
            <c:if test="${totalPage<= 1}" >
                <div id="pullUp"  style="display:none">
            </c:if>
                    <span class="pullUpIcon"></span><span class="pullUpLabel">上拉加载更多...</span>
                </div>


            </div>
        </div>
    </div>
<!--
    正文内容区结束
-->
<form name="shareform" id="shareform" action="${CONTEXT_PATH}/share" method="post">
    <input type="hidden" id="accountTypeName" name="accountTypeName" value="${accountTypeName}"/>
    <input type="hidden" id="publicSource" name="publicSource" value="${publicSource}"/>
    <input type="hidden" id="accountType" name="accountType" value="${accountType}"/>
    <input type="hidden"  name="sendType" id="sendType" value=""/>
    <input type="hidden"  name="publicType" id="publicType" value="${publicType}"/>
    <input type="hidden"  name="cardNo" id="cardNo" value="${cardNo}"/>
</form>
<c:if test="${publicType==2}">
    <div class="fenxiangdao"><a onclick="sharedo(1)" class="fl" style="width:50%">
        <img src="images/z_57.jpg"/>分享到好友</a>
        <a onclick="sharedo(2)" style="width:46%" class="fl"><img src="images/z_58.jpg"/>分享到群</a>
            <%--<a href="#" class="fr noright">
             <img src="${ctx}/html/images/z_59.jpg" />存入微信卡包</a>&ndash;%&gt;--%>
    </div>
</c:if>
</body>

</html>
<script>
    function sharedo(st) {

        $("#sendType").val(st);
        $("#shareform").submit();
    }
    function sydo(useType) {

    }
</script>