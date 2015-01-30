window.Campaign = 
  addColumn: ->
    colnum = $("#campaignForm .campaign-column").length
    colnum += 1
    new_column = '<div class="form-group campaign-column new-column" data-index="' + colnum + '">'
    new_column += '  <label for="name" style="min-width:55px;">* 字段#1</label>'
    new_column += '  <input class="form-control require column" onkeyup="Campaign.inputMonitor();" onchange="Campaign.inputMonitor();" oninput="Campaign.inputMonitor();" name="campaign[column' + colnum + ']" placeholder="column' + colnum + '" style="width:20%;min-width:20px;display:inline;" type="text" value="">'
    new_column += '  <a class="btn btn-default btn-sm btn-danger" href="javascript:void(0);" onclick="Campaign.removeColumn(this);"><span class="glyphicon glyphicon-minus"></span></a>'
    new_column += '  <span class="alert alert-danger" style="display:inline;padding:5px;">不可为空;</span>'
    new_column += '</div>'
    $("#campaignForm .add-column").last().before(new_column)
    Campaign.renameColumn()
    Campaign.inputMonitor()

  renameColumn: ->
    $("#campaignForm .campaign-column").each (index) ->
      column_index = index + 1
      text = "字段#" + column_index
      $(this).attr("data-index", column_index)
      $label = $(this).children("label:first")

      $label.html(text + "*") if $label.text() != text + "*"
      $input = $(this).children("input")
      text = text + " 名称"
      $input.attr("placeholder", text) if $input.attr("placeholder") != text
      $input.attr("name", "campaign[column" + column_index + "]")

  removeColumn: (self) ->
    $this = $(self).parent(".campaign-column").first()
    $this.remove()
    Campaign.renameColumn()
    Campaign.inputMonitor()


  inputMonitor: ->
    #keywords = $("input[name='campaign[keywords]']").val().split(/,/)
    disabled_submit = false
    columns = []
    $("#campaignForm").find(".require").each ->
      $this = $(this)
      value = $.trim($this.val())
      $warn = $this.siblings(".alert-danger")
      #默认没有错误
      is_error = false
      warn = ""
      #name, column-n不可为空
      is_error = true if(!value.length)
      warn = "不可为空;" if(is_error)

      if value.length && $this.hasClass("column")
        #column-n不可以与关键字冲突
        #if($.inArray(value, keywords)>=0)
        #  is_error = true
        #  warn += "关键字冲突;"
        #column-n不可重复
        if($.inArray(value, columns)>=0)
          is_error = true
          warn += "字段名重复;"
        columns.push(value)

      if is_error == true then $warn.removeClass("hidden") else $warn.addClass("hidden")
      $warn.html(warn)
      disabled_submit = true if(is_error) 

      #默认为false，有一个错误就设置为true
      if(disabled_submit==true) 
        $("button[type='submit']").attr("disabled","disabled") 
      else
        $("button[type='submit']").removeAttr("disabled")

  checkbox: (self) ->
    state = $(self).attr("checked")
    if(state == undefined || state == "undefined")
      $(self).attr("checked", "true")
    else
      $(self).removeAttr("checked")

  codeIframeWhetherDesign: (self, form) ->
    state = $(self).attr("checked")
    if(state == undefined || state == "undefined")
      $(self).attr("checked", "true")
      $(form).removeClass("hidden")
    else
      $(self).removeAttr("checked")
      $(form).addClass("hidden")

  codeIframeFormRemoveColumn: (self, column, k) ->
    state = $(self).attr("checked")
    $labels = $("."+ column + "-" + k + "-label")
    $inputs = $("."+ column + "-" + k + "-input")
    if(state == undefined || state == "undefined")
      $(self).attr("checked", "true")
      $labels.addClass("strike")
      $inputs.addClass("strike")
      $inputs.attr("disabled", "disabled")
    else
      $(self).removeAttr("checked")
      $labels.removeClass("strike")
      $inputs.removeClass("strike")
      $inputs.removeAttr("disabled")

  postCampaignTemplate: (token, params) ->
    $.ajax
        url: "/campaigns/template"
        type: "post"
        data: { token: token, template: params }
        success: (data) ->
          # show successfully information
          time_now = new Date().toString()
          $("#codeIframeAlertSuccess").html("更新成功 - " + time_now)
          $("#codeIframeAlertSuccess").removeClass("hidden")
          $("#codeIframeAlertDanger").addClass("hidden")


  escapeHTML: (string) ->
    entityMap =
      "&": "&amp;"
      "<": "&lt;"
      ">": "&gt;"
      "\"": "&quot;"
      "'": "&#39;"
      "/": "&#x2F;"
    String(string).replace /[&<>"'\/]/g, (s) ->
      entityMap[s]

