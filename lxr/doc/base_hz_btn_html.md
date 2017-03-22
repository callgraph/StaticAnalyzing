<style type="text/css">
body,ul,li{ margin:0; padding:0; font-size:13px;}
ul,li{list-style:none;}

#divselect{width:186px; padding-right:-210px; margin:30px auto; position:absolute;right:0px; z-index:10000;}
#divselect cite{width:150px; height:24px; line-height:24px; display:block; color:#0000ff;
		cursor:pointer;font-style:normal;
		padding-left:4px; padding-right:30px; border:1px solid #333333;
		background:url(./templates/html/html_head_btn_files/xjt.png) no-repeat right center;}
		<!--以上代码均是用于限定最上方下拉框的，其中，第5行参数"position"及"right"用于固定整个框的位置-->
		<!--第6行参数"color"用于设定下拉框默认显示文字颜色-->
#divselect ul{width:184px; border:1px solid #333333; background-color:#ffffff; position:absolute; 
		z-index:20000; margin-top:-1px; display:none;}
#divselect ul li{height:20px; line-height:20px;}
#divselect ul li a{display:block; height:23px; color:#0000ff; text-decoration:none; padding-left:10px;
		   padding-right:10px;}
		   <!--第15行参数"color"用于设定下拉框中各个选项文字颜色-->
#divselect ul li a:hover{background-color:#ccc;}
</style>
