import UIKit
import UIKit

// Node sınıfı
class Node {
    var x: Int
    var y: Int
    var parent: Node?

    init(x: Int, y: Int, parent: Node? = nil) {
        self.x = x
        self.y = y
        self.parent = parent
    }
}

// ViewController sınıfı
class ViewController: UIViewController {
    

    @IBOutlet weak var matrixLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UILabel ekleyin ve boyutlandırın
        
        matrixLabel.numberOfLines = 0
        matrixLabel.textAlignment = .center
        matrixLabel.frame = CGRect(x: 20, y: 100, width: self.view.frame.width - 40, height: 400) // Yüksekliği artırdım
        matrixLabel.font = UIFont.systemFont(ofSize: 20) // Yazı tipi boyutunu ayarlayın
        view.addSubview(matrixLabel)
        
        // actionsMatrix'i tanımlayın
        let actionsMatrix: [[Int]] = [
            [9, 9, 9, 9, 9, 9],
            [9, 1, 2, 1, 5, 9], // 2'yi ekledim, bu temizlenecek alan
            [9, 1, 0, 1, 0, 9],
            [9, 1, 0, 1, 0, 9],
            [9, 3, 0, 3, 0, 9],
            [9, 9, 9, 9, 9, 9]
        ]

        // CleaningRobot nesnesini başlatın ve temizlemeyi başlatın
        let cleaningRobot = CleaningRobot(matrix: actionsMatrix, startX: 1, startY: 1, viewController: self)
        cleaningRobot.clean()
    }

    // Matrisin güncellenmiş halini UILabel'de göstermek için fonksiyon
    func updateMatrixDisplay(matrixText: String) {
        matrixLabel.text = matrixText
    }
}

// CleaningRobot sınıfı
class CleaningRobot {
    var matrix: [[Int]]
    var stack: [Node] = []
    var solution: [Node] = []
    var currLine: Int
    var currCol: Int
    weak var viewController: ViewController?

    init(matrix: [[Int]], startX: Int, startY: Int, viewController: ViewController) {
        self.matrix = matrix
        self.currLine = startX
        self.currCol = startY
        self.viewController = viewController
        stack.append(Node(x: startX, y: startY))
        solution.append(Node(x: startX, y: startY))
    }

    func renderMatrix() {
        let matrixText = matrix.map { row in
            row.map { $0 == 0 ? "⬜️" : $0 == 1 ? "⬛️" : "🟫" }.joined(separator: " ")
        }.joined(separator: "\n")
        
        // UIViewController içindeki UILabel'i güncelle
        viewController?.updateMatrixDisplay(matrixText: matrixText)
    }
    
    func mapNotClean() -> Bool {
        for row in matrix {
            if row.contains(2) { // 2'yi kontrol et
                return true
            }
        }
        return false
    }

    func lookAround(x: Int, y: Int, node: Node) -> Node? {
        let directions = [(-1, 0), (1, 0), (0, -1), (0, 1)] // Yukarı, Aşağı, Sol, Sağ
        for (dx, dy) in directions {
            let newX = x + dx, newY = y + dy
            if newX >= 0 && newX < matrix.count && newY >= 0 && newY < matrix[newX].count {
                if matrix[newX][newY] != 1 { // Engelleri kontrol et
                    let newNode = Node(x: newX, y: newY, parent: node)
                    if matrix[newX][newY] == 2 { // Temizlenecek alan
                        return newNode
                    }
                    stack.append(newNode)
                }
            }
        }
        return nil
    }

    func discoverPath() -> Node? {
        while !stack.isEmpty {
            let node = stack.removeFirst()
            if let nextNode = lookAround(x: node.x, y: node.y, node: node) {
                return nextNode
            }
        }
        return nil
    }

    func clean() {
        while mapNotClean() {
            if let path = discoverPath() {
                var currentNode: Node? = path
                while let node = currentNode {
                    solution.append(node)
                    matrix[node.x][node.y] = 0 // Temizlenmiş alan
                    currentNode = node.parent
                }
            }
            renderMatrix() // Matrisin güncellenmiş halini render et
        }
        print("Temizlik tamamlandı!")
    }
}
