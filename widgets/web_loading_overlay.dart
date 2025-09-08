// lib/widgets/web_loading_overlay.dart

import 'package:flutter/material.dart';
import 'dart:html' as html;

class WebLoadingOverlay extends StatefulWidget {
  final bool isLoading;
  final String message;
  final Widget child;

  const WebLoadingOverlay({
    Key? key,
    required this.isLoading,
    this.message = 'Loading...',
    required this.child,
  }) : super(key: key);

  @override
  State<WebLoadingOverlay> createState() => _WebLoadingOverlayState();
}

class _WebLoadingOverlayState extends State<WebLoadingOverlay> {
  html.DivElement? _loadingDiv;
  
  @override
  void initState() {
    super.initState();
    _createLoadingElement();
  }
  
  @override
  void didUpdateWidget(WebLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _showLoading();
      } else {
        _hideLoading();
      }
    }
    
    if (widget.message != oldWidget.message && _loadingDiv != null) {
      _updateMessage();
    }
  }
  
  @override
  void dispose() {
    _removeLoadingElement();
    super.dispose();
  }
  
  void _createLoadingElement() {
    _loadingDiv = html.DivElement()
      ..id = 'flutter-web-loading-overlay'
      ..style.position = 'fixed'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = 'rgba(0, 0, 0, 0.5)'
      ..style.display = 'none'
      ..style.zIndex = '9999'
      ..style.justifyContent = 'center'
      ..style.alignItems = 'center'
      ..style.flexDirection = 'column';
    
    final spinnerDiv = html.DivElement()
      ..className = 'spinner'
      ..style.width = '50px'
      ..style.height = '50px'
      ..style.border = '5px solid rgba(255, 255, 255, 0.3)'
      ..style.borderRadius = '50%'
      ..style.borderTopColor = '#fff'
      ..style.animation = 'spin 1s linear infinite';
    
    final messageDiv = html.DivElement()
      ..id = 'loading-message'
      ..style.color = 'white'
      ..style.marginTop = '20px'
      ..style.fontFamily = 'Arial, sans-serif'
      ..style.fontSize = '16px'
      ..style.fontWeight = 'bold'
      ..text = widget.message;
    
    // Add keyframes for spinner animation
    final styleElement = html.StyleElement()
      ..type = 'text/css'
      ..innerHtml = '''
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      ''';
    
    html.document.head?.append(styleElement);
    _loadingDiv!.append(spinnerDiv);
    _loadingDiv!.append(messageDiv);
    html.document.body?.append(_loadingDiv!);
    
    if (widget.isLoading) {
      _showLoading();
    }
  }
  
  void _showLoading() {
    if (_loadingDiv != null) {
      _loadingDiv!.style.display = 'flex';
    }
  }
  
  void _hideLoading() {
    if (_loadingDiv != null) {
      _loadingDiv!.style.display = 'none';
    }
  }
  
  void _updateMessage() {
    final messageElement = html.document.getElementById('loading-message');
    if (messageElement != null) {
      messageElement.text = widget.message;
    }
  }
  
  void _removeLoadingElement() {
    _loadingDiv?.remove();
    _loadingDiv = null;
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
