import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glovoapotheka/data/models/product.dart'; // Your ProductModel
import 'package:glovoapotheka/features/search/cubit/search_cubit.dart';
import 'package:glovoapotheka/features/search/cubit/search_state.dart';

class CustomSearchWithOverlay extends StatefulWidget {
  const CustomSearchWithOverlay({super.key});

  @override
  State<CustomSearchWithOverlay> createState() => _CustomSearchWithOverlayState();
}

class _CustomSearchWithOverlayState extends State<CustomSearchWithOverlay> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _showSuggestions = false;
  OverlayEntry? _overlayEntry;
  final GlobalKey _searchKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _showOverlay();
      } else {
        _hideOverlay();
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox = _searchKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5,
        width: size.width,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                } else if (state is SearchLoaded) {
                  if (state.results.isEmpty) {
                    return const SizedBox(
                      height: 60,
                      child: Center(child: Text('No products found.')),
                    );
                  }
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: state.results.map((product) {
                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text('${product.form} - ${product.priceCents}'),
                          onTap: () {
                            print('Selected product: ${product.name}');
                            _controller.text = product.name;
                            _hideOverlay();
                            _focusNode.unfocus();
                          },
                        );
                      }).toList(),
                    ),
                  );
                } else if (state is SearchError) {
                  return SizedBox(
                    height: 60,
                    child: Center(child: Text('Error: ${state.message}')),
                  );
                } else {
                  return const SizedBox(
                    height: 60,
                    child: Center(child: Text('Start typing to search...')),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: _searchKey,
      controller: _controller,
      focusNode: _focusNode,
      onChanged: (query) {
        context.read<SearchCubit>().search(query);
      },
      decoration: const InputDecoration(
        hintText: 'Search for products...',
        suffixIcon: Icon(Icons.search),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }
}

/*    
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: "Enter medication name...",
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ),
        
        // Search button
        Container(
          width: 120,
          height: 60,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search),
                SizedBox(width: 4),
                Text("Search", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
*/
