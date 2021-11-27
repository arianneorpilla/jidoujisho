package com.pichillilorenzo.flutter_inappwebview.plugin_scripts_js;

import com.pichillilorenzo.flutter_inappwebview.types.PluginScript;
import com.pichillilorenzo.flutter_inappwebview.types.UserContentController;
import com.pichillilorenzo.flutter_inappwebview.types.UserScriptInjectionTime;

public class PluginScriptsUtil {

  public static final String VAR_PLACEHOLDER_VALUE = "$IN_APP_WEBVIEW_PLACEHOLDER_VALUE";
  public static final String VAR_CONTENT_WORLD_NAME_ARRAY = "$IN_APP_WEBVIEW_CONTENT_WORLD_NAME_ARRAY";
  public static final String VAR_CONTENT_WORLD_NAME = "$IN_APP_WEBVIEW_CONTENT_WORLD_NAME";
  public static final String VAR_JSON_SOURCE_ENCODED = "$IN_APP_WEBVIEW_JSON_SOURCE_ENCODED";
  public static final String VAR_FUNCTION_ARGUMENT_NAMES = "$IN_APP_WEBVIEW_FUNCTION_ARGUMENT_NAMES";
  public static final String VAR_FUNCTION_ARGUMENT_VALUES = "$IN_APP_WEBVIEW_FUNCTION_ARGUMENT_VALUES";
  public static final String VAR_FUNCTION_ARGUMENTS_OBJ = "$IN_APP_WEBVIEW_FUNCTION_ARGUMENTS_OBJ";
  public static final String VAR_FUNCTION_BODY = "$IN_APP_WEBVIEW_FUNCTION_BODY";
  public static final String VAR_RESULT_UUID = "$IN_APP_WEBVIEW_RESULT_UUID";
  public static final String VAR_RANDOM_NAME = "$IN_APP_WEBVIEW_VARIABLE_RANDOM_NAME";

  public static final String CALL_ASYNC_JAVA_SCRIPT_WRAPPER_JS_SOURCE = "(function(obj) {" +
          "  (async function(" + VAR_FUNCTION_ARGUMENT_NAMES + ") {" +
          "    " + VAR_FUNCTION_BODY +
          "  })(" + VAR_FUNCTION_ARGUMENT_VALUES + ").then(function(value) {" +
          "    window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + ".callHandler('callAsyncJavaScript', {'value': value, 'error': null, 'resultUuid': '" + VAR_RESULT_UUID + "'});" +
          "  }).catch(function(error) {" +
          "    window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + ".callHandler('callAsyncJavaScript', {'value': null, 'error': error + '', 'resultUuid': '" + VAR_RESULT_UUID + "'});" +
          "  });" +
          "  return null;" +
          "})(" + VAR_FUNCTION_ARGUMENTS_OBJ + ");";

  public static final String EVALUATE_JAVASCRIPT_WITH_CONTENT_WORLD_WRAPPER_JS_SOURCE = "var $IN_APP_WEBVIEW_VARIABLE_RANDOM_NAME = null;" +
          "try {" +
          "  $IN_APP_WEBVIEW_VARIABLE_RANDOM_NAME = eval(" + VAR_PLACEHOLDER_VALUE + ");" +
          "} catch(e) {" +
          "  console.error(e);" +
          "}" +
          "window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + ".callHandler('evaluateJavaScriptWithContentWorld', {'value': $IN_APP_WEBVIEW_VARIABLE_RANDOM_NAME, 'resultUuid': '" + VAR_RESULT_UUID + "'});";

  public static final String IS_ACTIVE_ELEMENT_INPUT_EDITABLE_JS_SOURCE =
          "var activeEl = document.activeElement;" +
                  "var nodeName = (activeEl != null) ? activeEl.nodeName.toLowerCase() : '';" +
                  "var isActiveElementInputEditable = activeEl != null && " +
                  "(activeEl.nodeType == 1 && (nodeName == 'textarea' || (nodeName == 'input' && /^(?:text|email|number|search|tel|url|password)$/i.test(activeEl.type != null ? activeEl.type : 'text')))) && " +
                  "!activeEl.disabled && !activeEl.readOnly;" +
                  "var isActiveElementEditable = isActiveElementInputEditable || (activeEl != null && activeEl.isContentEditable) || document.designMode === 'on';";

  // android Workaround to hide context menu when selected text is empty
  // and the document active element is not an input element.
  public static final String CHECK_CONTEXT_MENU_SHOULD_BE_HIDDEN_JS_SOURCE = "(function(){" +
          "  var txt;" +
          "  if (window.getSelection) {" +
          "    txt = window.getSelection().toString();" +
          "  } else if (window.document.getSelection) {" +
          "    txt = window.document.getSelection().toString();" +
          "  } else if (window.document.selection) {" +
          "    txt = window.document.selection.createRange().text;" +
          "  }" +
          IS_ACTIVE_ELEMENT_INPUT_EDITABLE_JS_SOURCE +
          "  return txt === '' && !isActiveElementEditable;" +
          "})();";

  // By Jamie Birch, https://stackoverflow.com/questions/13438391/preventing-text-in-rt-tags-furigana-from-being-selected
  public static final String GET_SELECTED_TEXT_JS_SOURCE = "(function(){" +
                "    function getRangeSelectedNodes(range) {" +
                "      var node = range.startContainer;" +
                "      var endNode = range.endContainer;" +
                "      if (node == endNode) return [node];" +
                "      var rangeNodes = [];" +
                "      while (node && node != endNode) rangeNodes.push(node = nextNode(node));" +
                "      node = range.startContainer;" +
                "      while (node && node != range.commonAncestorContainer) {" +
                "        rangeNodes.unshift(node);" +
                "        node = node.parentNode;" +
                "      }" +
                "      return rangeNodes;" +
                "      function nextNode(node) {" +
                "        if (node.hasChildNodes()) return node.firstChild;" +
                "        else {" +
                "          while (node && !node.nextSibling) node = node.parentNode;" +
                "          if (!node) return null;" +
                "          return node.nextSibling;" +
                "        }" +
                "      }" +
                "    }" +
                "    var txt = \"\";" +
                "    var nodesInRange;" +
                "    var selection;" +
                "    if (window.getSelection) {" +
                "      selection = window.getSelection();" +
                "      nodesInRange = getRangeSelectedNodes(selection.getRangeAt(0));" +
                "      nodes = nodesInRange.filter((node) => node.nodeName == \"#text\" && node.parentElement.nodeName !== \"RT\" && node.parentElement.nodeName !== \"RP\" && node.parentElement.parentElement.nodeName !== \"RT\" && node.parentElement.parentElement.nodeName !== \"RP\");" +
                "      if (selection.anchorNode === selection.focusNode) {" +
                "          txt = txt.concat(selection.anchorNode.textContent.substring(selection.baseOffset, selection.extentOffset));" +
                "      } else {" +
                "          for (var i = 0; i < nodes.length; i++) {" +
                "              var node = nodes[i];" +
                "              if (i === 0) {" +
                "                  txt = txt.concat(node.textContent.substring(selection.getRangeAt(0).startOffset));" +
                "              } else if (i === nodes.length - 1) {" +
                "                  txt = txt.concat(node.textContent.substring(0, selection.getRangeAt(0).endOffset));" +
                "              } else {" +
                "                  txt = txt.concat(node.textContent);" +
                "              }" +
                "          }" +
                "      }" +
                "    } else if (window.document.getSelection) {" +
                "      selection = window.document.getSelection();" +
                "      nodesInRange = getRangeSelectedNodes(selection.getRangeAt(0));" +
                "      nodes = nodesInRange.filter((node) => node.nodeName == \"#text\" && node.parentElement.nodeName !== \"RT\" && node.parentElement.nodeName !== \"RP\" && node.parentElement.parentElement.nodeName !== \"RT\" && node.parentElement.parentElement.nodeName !== \"RP\");" +
                "      if (selection.anchorNode === selection.focusNode) {" +
                "          txt = txt.concat(selection.anchorNode.textContent.substring(selection.baseOffset, selection.extentOffset));" +
                "      } else {" +
                "          for (var i = 0; i < nodes.length; i++) {" +
                "              var node = nodes[i];" +
                "              if (i === 0) {" +
                "                  txt = txt.concat(node.textContent.substring(selection.getRangeAt(0).startOffset));" +
                "              } else if (i === nodes.length - 1) {" +
                "                  txt = txt.concat(node.textContent.substring(0, selection.getRangeAt(0).endOffset));" +
                "              } else {" +
                "                  txt = txt.concat(node.textContent);" +
                "              }" +
                "          }" +
                "      }" +
                "    } else if (window.document.selection) {" +
                "      txt = window.document.selection.createRange().text;" +
                "    }" +
                "    return txt;" +
          "})();";

  public static final String CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT_GROUP_NAME = "CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT";
  public static final PluginScript CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT = new PluginScript(
          PluginScriptsUtil.CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT_GROUP_NAME,
          PluginScriptsUtil.CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_SOURCE,
          UserScriptInjectionTime.AT_DOCUMENT_START,
          null,
          false
  );

  // android Workaround to hide context menu when user emit a keydown event
  public static final String CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_SOURCE = "(function(){" +
          "  document.addEventListener('keydown', function(e) {" +
          "    window." + JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_NAME + "._hideContextMenu();" +
          "  });" +
          "})();";
}
