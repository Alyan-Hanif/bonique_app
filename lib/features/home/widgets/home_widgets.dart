import 'package:flutter/material.dart';

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key, required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Hello, \\${name.isEmpty ? 'Guest' : name}',
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class TryOnBtn extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  const TryOnBtn({
    super.key ,
    required this.text,
    required this.onPressed,
    required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 382,
      height: 48,
        child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B1A18),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48),
            side: const BorderSide(
              color: Colors.white,
              width: 1,
            ),
          ),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(text),
      ),
    );

  }
}



//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 327, // fixed width
//       height: 48, // fixed height
//       child: ElevatedButton(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color(0xFF1B1A18),
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(48),
//             side: const BorderSide(
//               color: Colors.white,
//               width: 1,
//             ),
//           ),
//           elevation: 0,
//         ),
//         onPressed: isLoading ? null : onPressed,
//         child: isLoading
//             ? const SizedBox(
//           width: 24,
//           height: 24,
//           child: CircularProgressIndicator(
//             color: Colors.white,
//             strokeWidth: 2,
//           ),
//         )
//             : Text(text, style: AuthTextStyles.button),
//       ),
//     );
//   }
// }
