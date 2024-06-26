import 'package:image/image.dart' as img;

class ChessBoardProcessor {
  img.Image preprocessImage(img.Image image) {
    // Resize image to a standard size
    image = img.copyResize(image, width: 400, height: 400);
    // Convert to grayscale
    return img.grayscale(image);
  }

  List<img.Image> segmentBoard(img.Image image) {
    final squares = <img.Image>[];
    final squareSize = image.width ~/ 8;
    
    for (int y = 0; y < 8; y++) {
      for (int x = 0; x < 8; x++) {
        final square = img.copyCrop(image, 
          x: x * squareSize, 
          y: y * squareSize, 
          width: squareSize, 
          height: squareSize
        );
        squares.add(square);
      }
    }
    
    return squares;
  }

  double compareSquares(img.Image square1, img.Image square2) {
    // Simple Mean Squared Error (MSE) comparison
    double mse = 0;
    for (int y = 0; y < square1.height; y++) {
      for (int x = 0; x < square1.width; x++) {
        final pixel1 = square1.getPixel(x, y);
        final pixel2 = square2.getPixel(x, y);
        mse += (pixel1 - pixel2) * (pixel1 - pixel2);
      }
    }
    return mse / (square1.width * square1.height);
  }

  (bool, List<String>) detectChanges(img.Image image1, img.Image image2, {double threshold = 1000}) {
    final prep1 = preprocessImage(image1);
    final prep2 = preprocessImage(image2);

    final squares1 = segmentBoard(prep1);
    final squares2 = segmentBoard(prep2);

    final changes = <String>[];
    for (int i = 0; i < 64; i++) {
      final similarity = compareSquares(squares1[i], squares2[i]);
      if (similarity > threshold) {
        changes.add(_coordinateToChessNotation(i ~/ 8, i % 8));
      }
    }

    return (changes.isNotEmpty, changes);
  }

  String _coordinateToChessNotation(int row, int col) {
    final columns = 'hgfedcba';
    return '${columns[col]}${row + 1}';
  }
}