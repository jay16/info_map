(function() {
  window.Campaign = {
    addColumn: function() {
      var colnum, new_column;
      colnum = $("#campaignForm .campaign-column").length;
      colnum += 1;
      new_column = '<div class="form-group campaign-column new-column" data-index="' + colnum + '">';
      new_column += '  <label for="name" style="min-width:55px;">字段#1</label>';
      new_column += '  <input class="form-control require column" onkeyup="Campaign.inputMonitor();" onchange="Campaign.inputMonitor();" oninput="Campaign.inputMonitor();" name="campaign[column' + colnum + ']" placeholder="column' + colnum + '" style="width:20%;min-width:20px;display:inline;" type="text" value="">';
      new_column += '  <a class="btn btn-default btn-sm btn-danger" href="javascript:void(0);" onclick="Campaign.removeColumn(this);"><span class="glyphicon glyphicon-minus"></span></a>';
      new_column += '  <a class="btn btn-default btn-sm btn-info" href="javascript:void(0);" onclick="Campaign.addColumnConstraint(this);"><span class="glyphicon glyphicon-plus"></span></a>';
      new_column += '  <span class="alert alert-danger" style="display:inline;padding:5px;">不可为空;</span>';
      new_column += '</div>';
      $("#campaignForm .add-column").last().before(new_column);
      Campaign.renameColumn();
      return Campaign.inputMonitor();
    },
    addColumnConstraint: function(self) {
      return $("#columnConstraint").modal("show");
    },
    renameColumn: function() {
      return $("#campaignForm .campaign-column").each(function(index) {
        var $input, $label, column_index, text;
        column_index = index + 1;
        text = "字段 #" + column_index;
        $(this).attr("data-index", column_index);
        $label = $(this).children("label:first");
        if ($label.text() !== text) {
          $label.html(text);
        }
        $input = $(this).children("input");
        text = text + " 名称";
        if ($input.attr("placeholder") !== text) {
          $input.attr("placeholder", text);
        }
        return $input.attr("name", "campaign[column" + column_index + "]");
      });
    },
    removeColumn: function(self) {
      var $this;
      $this = $(self).parent(".campaign-column").first();
      $this.remove();
      Campaign.renameColumn();
      return Campaign.inputMonitor();
    },
    inputMonitor: function() {
      var columns, disabled_submit;
      disabled_submit = false;
      columns = [];
      return $("#campaignForm").find(".require").each(function() {
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
    }
  };

}).call(this);
