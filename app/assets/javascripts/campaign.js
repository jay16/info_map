(function() {
  window.Campaign = {
    addColumn: function() {
      var colnum, new_column;
      colnum = $(".campaign-column").length;
      colnum += 1;
      new_column = '<div class="form-group campaign-column new-column-' + colnum + '" data-index="' + colnum + '">';
      new_column += '  <label for="name" style="min-width:55px;">字段 ' + colnum + '* </label>';
      new_column += '  <input class="form-control require column" onkeyup="Campaign.inputMonitor();" onchange="Campaign.inputMonitor();" oninput="Campaign.inputMonitor();" name="campaign[column' + colnum + ']" placeholder="column' + colnum + '" style="width:50%;display:inline;" type="text" value="">';
      new_column += '  <a class="btn btn-default btn-sm btn-danger" href="javascript:void(0);" onclick="Campaign.removeColumn(this,' + colnum + ');">移除</a>';
      new_column += '  <span class="alert alert-danger" style="display:inline;padding:5px;">不可为空;</span>';
      new_column += '</div>';
      $(".campaign-column a").attr("disabled", "disabled");
      $("#campaign_form .form-group").last().after(new_column);
      $("input[name='campaign[colnum]']").val(colnum);
      return Campaign.inputMonitor();
    },
    removeColumn: function(self, index) {
      var $this, pre_index;
      $this = $(self).parent(".campaign-column").first();
      index = parseInt($this.data("index"));
      pre_index = index - 1;
      $(".new-column-" + pre_index + " a").removeAttr("disabled");
      $("input[name='campaign[colnum]']").val(pre_index);
      $this.remove();
      return Campaign.inputMonitor();
    },
    inputMonitor: function() {
      var columns, disabled_submit, keywords;
      keywords = $("input[name='campaign[keywords]']").val().split(/,/);
      disabled_submit = false;
      columns = [];
      return $("#campaign_form").find(".require").each(function() {
        var $this, $warn, is_error, value, warn;
        $this = $(this);
        value = $.trim($this.val());
        $warn = $this.siblings(".alert-danger");
        is_error = false;
        warn = "";
        if (!value.length) {
          is_error = true;
        }
        if (is_error) {
          warn = "不可为空;";
        }
        if (value.length && $this.hasClass("column")) {
          if ($.inArray(value, keywords) >= 0) {
            is_error = true;
            warn += "关键字冲突;";
          }
          if ($.inArray(value, columns) >= 0) {
            is_error = true;
            warn += "字段名重复;";
          }
          columns.push(value);
        }
        if (is_error === true) {
          $warn.removeClass("hidden");
        } else {
          $warn.addClass("hidden");
        }
        $warn.html(warn);
        if (is_error) {
          disabled_submit = true;
        }
        if (disabled_submit === true) {
          return $("button[type='submit']").attr("disabled", "disabled");
        } else {
          return $("button[type='submit']").removeAttr("disabled");
        }
      });
    },
    checkbox: function(self) {
      var state;
      state = $(self).attr("checked");
      if (state === void 0 || state === "undefined") {
        return $(self).attr("checked", "true");
      } else {
        return $(self).removeAttr("checked");
      }
    },
    codeIframeWhetherDesign: function(self, form) {
      var state;
      state = $(self).attr("checked");
      if (state === void 0 || state === "undefined") {
        $(self).attr("checked", "true");
        return $(form).removeClass("hidden");
      } else {
        $(self).removeAttr("checked");
        return $(form).addClass("hidden");
      }
    },
    codeIframeFormRemoveColumn: function(self, column, k) {
      var $inputs, $labels, state;
      state = $(self).attr("checked");
      $labels = $("." + column + "-" + k + "-label");
      $inputs = $("." + column + "-" + k + "-input");
      if (state === void 0 || state === "undefined") {
        $(self).attr("checked", "true");
        $labels.addClass("strike");
        $inputs.addClass("strike");
        return $inputs.attr("disabled", "disabled");
      } else {
        $(self).removeAttr("checked");
        $labels.removeClass("strike");
        $inputs.removeClass("strike");
        return $inputs.removeAttr("disabled");
      }
    },
    postCampaignTemplate: function(token, params) {
      return $.ajax({
        url: "/campaigns/template",
        type: "post",
        data: {
          token: token,
          template: params
        },
        success: function(data) {
          var time_now;
          time_now = new Date().toString();
          $("#codeIframeAlertSuccess").html("更新成功 - " + time_now);
          $("#codeIframeAlertSuccess").removeClass("hidden");
          return $("#codeIframeAlertDanger").addClass("hidden");
        }
      });
    },
    escapeHTML: function(string) {
      var entityMap;
      entityMap = {
        "&": "&amp;",
        "<": "&lt;",
        ">": "&gt;",
        "\"": "&quot;",
        "'": "&#39;",
        "/": "&#x2F;"
      };
      return String(string).replace(/[&<>"'\/]/g, function(s) {
        return entityMap[s];
      });
    },
    codeIframeFormSubmit: function() {
      var params, token, url;
      url = $("input[name='code-iframe-url']").val();
      token = $("input[name='code-iframe-token']").val();
      params = new Array();
      $(".code-iframe-whether-remove").each(function() {
        var column, klass, state, _ref;
        state = $(this).attr("checked");
        column = $(this).data("column");
        klass = $(this).data("klass");
        return params.push(column + "[" + klass + "][isuse]=" + ((_ref = state === void 0) != null ? _ref : {
          "true": "false"
        }));
      });
      $(".code-iframe-column").each(function() {
        var column, klass, value;
        column = $(this).data("column");
        klass = $(this).data("klass");
        value = Campaign.escapeHTML($(this).val());
        return params.push(column + "[" + klass + "][text]=" + value);
      });
      $(".code-iframe-select").each(function() {
        var column, value;
        column = $(this).data("column");
        value = $(this).val();
        return params.push(column + "[span]=" + value);
      });
      $(".code-iframe-whether-required").each(function() {
        var column, state, _ref;
        state = $(this).attr("checked");
        column = $(this).data("column");
        return params.push(column + "[required]=" + ((_ref = state === "checked") != null ? _ref : {
          "true": "false"
        }));
      });
      $(".code-iframe-feedback").each(function() {
        var value;
        value = $(this).val();
        return params.push("feedback=" + value);
      });
      url = url + "&" + params.join("&");
      console.log(url);
      Campaign.postCampaignTemplate(token, params.join("&"));
      return $("#iframe").attr("src", url);
    },
    selectMonitor: function() {
      var span;
      span = 0;
      $("select").each(function() {
        if ($(this).hasClass("code-iframe-select")) {
          return span += parseInt($(this).val());
        }
      });
      if (span > 12) {
        $("#codeIframeAlertDanger").html("所有字段宽度之和应该小于等于12, 当前和为" + span);
        $("#codeIframeAlertSuccess").addClass("hidden");
        $("#codeIframeAlertDanger").removeClass("hidden");
        return $("#codeIframeSubmit").attr("disabled", "disabled");
      } else {
        $("#codeIframeAlertDanger").addClass("hidden");
        return $("#codeIframeSubmit").removeAttr("disabled");
      }
    },
    isReverse: function(self, token) {
      var state;
      state = $(self).attr("checked");
      if (state === void 0) {
        $("#reverseCheckbox").removeAttr("checked");
        return $("#reverseSettingModal").modal("show");
      } else {
        return $.ajax({
          url: "/campaigns/reverse",
          type: "get",
          data: {
            token: token,
            is_reverse: 0
          },
          success: function(data) {
            return window.location.reload();
          }
        });
      }
    },
    reverseMonitor: function(self) {
      if (($(self).val().length)) {
        return $("#reverseFormSubmit").removeAttr("disabled");
      } else {
        return $("#reverseFormSubmit").attr("disabled", "disabled");
      }
    },
    reverseSubmit: function(token) {
      var url;
      url = $("#inputReverse").val();
      return $.ajax({
        url: "/campaigns/reverse",
        type: "get",
        data: {
          token: token,
          url: url
        },
        success: function(data) {
          console.log(data);
          if (typeof data === "string") {
            data = eval("(" + data + ")");
          }
          if (data.valid === true) {
            $(".modal .alert-danger").addClass("hidden");
            window.location.reload();
            return $("#reverseSettingModal").modal("hide");
          } else {
            $(".modal .alert-danger").html(url + " - 验证无效 - " + new Date().toString());
            $(".modal .alert-danger").removeClass("hidden");
            return $("#reverseCheckbox").removeAttr("checked");
          }
        }
      });
    }
  };

  $(function() {
    Campaign.reverseMonitor("#inputReverse");
    Campaign.selectMonitor();
    $("select").bind("change click", function() {
      return Campaign.selectMonitor();
    });
    $("#inputReverse").bind("change input keyup", function() {
      return Campaign.reverseMonitor(this);
    });
    return $("#copy_btn").zclip({
      path: "http://solfie-cdn.qiniudn.com/ZeroClipboard-1.1.1.swf",
      copy: function() {
        return $("#entity_download_url").val();
      }
    });
  });

}).call(this);
