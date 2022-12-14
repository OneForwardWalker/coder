<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <meta name="renderer" content="webkit|ie-comp|ie-stand">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="format-detection" content="telephone=no">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <link rel="icon" type="image/x-icon" href="../static/icon/favicon_64.ico"/>
    <link rel="shortcut icon" type="image/x-icon" href="../static/icon/favicon_64.ico"/>
    <title>${pageTitle}</title>
    <!-- jQuery -->
    <script type="text/javascript" src="../static/dependent/jquery/jquery.min.js"></script>
    <!-- bootstrap -->
    <script type="text/javascript" src="../static/dependent/bootstrap/js/bootstrap.js"></script>
    <link type="text/css" rel="stylesheet" href="../static/dependent/bootstrap/css/bootstrap.min.css">
    <!-- bootstrap-table -->
    <script type="text/javascript" src="../static/dependent/bootstrap-table/1.9.1/bootstrap-table.js"></script>
    <script type="text/javascript" src="../static/dependent/bootstrap-table/1.9.1/bootstrap-table-locale-all.js"></script>
    <link rel="stylesheet" type="text/css" href="../static/dependent/bootstrap-table/1.9.1/bootstrap-table.css"/>
    <!--[if lt IE 9]>
    <script src="../static/dependent/bootstrap/plugins/ie/html5shiv.js"></script>
    <script src="../static/dependent/bootstrap/plugins/ie/respond.js"></script>
    <![endif]-->
    <!--[if lt IE 8]>
    <script src="../static/dependent/bootstrap/plugins/ie/json2.js"></script>
    <![endif]-->
    <!-- font-awesome -->
    <link rel="stylesheet" type="text/css" href="../static/dependent/fontAwesome/css/font-awesome.min.css" media="all"/>
    <!-- layer -->
    <script type="text/javascript" src="../static/dependent/layer/layer.js"></script>
    <!-- laydate -->
    <link rel="stylesheet" type="text/css" href="../static/dependent/laydate/need/laydate.css"/>
    <script type="text/javascript" src="../static/dependent/laydate/laydate.js"></script>
    <!-- base -->
    <link rel="stylesheet" href="../static/css/base.css">
</head>
<body>

<div class="container-fluid">

    <h4>????????????</h4>
    <div class="row-fluid">
        <div class="span12">
            <div class="control-group form-inline" style="border: 1px solid #ccc;padding: 10px; border-radius: 3px;">
                <div class="input-group input-group-sm">
                    <label for="name">????????????</label>
                    <input id="name" type="text">
                </div>
                <div class="input-group input-group-sm">
                    <label for="sex">??????</label>
                    <select id="sex">
                        <option value="-1">??????</option>
                        <option value="1">???</option>
                        <option value="0">???</option>
                    </select>
                </div>
                <div class="input-group input-group-sm">
                    <label for="sex">??????</label>
                    <input type="text" id="date" class="laydate-icon" style="margin: 10px 0;">
                </div>
                <button id="btn_search" type="button" class="btn btn-primary btn-sm">
                    <span class="glyphicon glyphicon-search" aria-hidden="true"></span>??????
                </button>
                <button id="btn_clean_search" type="button" class="btn btn-danger btn-sm">
                    ????????????
                </button>
            </div>
        </div>
    </div>

    <div id="toolbar" class="btn-group">
        <!-- ????????? -->
        <button id="btn_add" type="button" class="btn btn-default btn-sm">
            <span class="glyphicon glyphicon-plus" aria-hidden="true"></span>??????
        </button>
        <button id="btn_delete" type="button" class="btn btn-default btn-sm">
            <span class="glyphicon glyphicon-trash" aria-hidden="true"></span>??????
        </button>
        <button id="btn_refresh" type="button" class="btn btn-default btn-sm">
            <span class="glyphicon glyphicon-refresh" aria-hidden="true"></span>??????
        </button>
        <button id="btn_clean" type="button" class="btn btn-default btn-sm">??????</button>
        <button id="btn_init" type="button" class="btn btn-default btn-sm">?????????</button>
        <button id="btn_toggleview" type="button" class="btn btn-default btn-sm">????????????</button>
        <button id="btn_togglepage" type="button" class="btn btn-default btn-sm">????????????</button>
        <button id="btn_selectpage" type="button" class="btn btn-default btn-sm">??????</button>
    </div>

    <!-- ?????? -->
    <table id="users" class="table table-hover"></table>

    <!-- ????????????????????? -->
    <div class="modal fade" id="addAndUpdate" tabindex="-1" role="dialog" aria-labelledby="addAndUpdateLabel">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span
                            aria-hidden="true">??</span></button>
                    <h4 class="modal-title" id="addAndUpdateLabel">??????????????????</h4>
                </div>
                <div class="modal-body">
                    <input type="hidden" name="txt_type" class="form-control" id="txt_type" placeholder="????????????">
                    <input type="hidden" name="txt_id" class="form-control" id="txt_id" placeholder="??????">
                    <div class="form-group">
                        <label for="txt_name">??????</label>
                        <input type="text" name="txt_name" class="form-control" id="txt_name" placeholder="??????">
                    </div>
                    <div class="form-group">
                        <label class="control-label">??????</label>
                        <div class="controls">
                            <input id="p_man" type="radio" name="sex" value="1" checked/>
                            <label for="p_man" style="margin-right: 30px;">???</label>
                            <input id="p_woman" type="radio" name="sex" value="0"/>
                            <label for="p_woman">???</label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="txt_pwd">??????</label>
                        <input type="password" name="txt_pwd" class="form-control" id="txt_pwd" placeholder="??????">
                    </div>
                    <div class="form-group">
                        <label for="txt_email">??????</label>
                        <input type="text" name="txt_email" class="form-control" id="txt_email" placeholder="??????">
                    </div>
                    <div class="form-group">
                        <label for="txt_phone">??????</label>
                        <input type="text" name="txt_phone" class="form-control" id="txt_phone" placeholder="??????">
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default btn-sm" data-dismiss="modal">
                        <span class="glyphicon glyphicon-remove" aria-hidden="true"></span>??????
                    </button>
                    <button type="button" id="btn_add_update_submit" class="btn btn-primary btn-sm" data-dismiss="modal">
                        <span class="glyphicon glyphicon-floppy-disk" aria-hidden="true"></span>??????
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript" src="../static/js/laydate.js"></script>
<script type="text/javascript" src="../static/js/table.js"></script>
<script type="text/javascript" src="../static/js/table_crud.js"></script>
</body>
</html>
