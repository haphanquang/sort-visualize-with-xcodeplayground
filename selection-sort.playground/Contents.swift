import UIKit

let uiTime: UInt32 = 1200000

@discardableResult
func doSelectionSort(_ input: [Int], compareCallback: @escaping (Int, Int, Bool) -> ()) -> [Int] {
    var result = input
    
    for i in 0..<result.count - 1 {
        var minIndex = i
        
        for j in i+1..<result.count {
            let before = minIndex
            
            if result[j] < result[minIndex] {
                minIndex = j
            }
            
            compareCallback(j, before, false)
            
            usleep(uiTime)
        }
        
        if minIndex != i {
            result.swapAt(i, minIndex)
            compareCallback(i, minIndex, true)
        }else {
            compareCallback(i, i, true)
        }
        
        usleep(uiTime)
    }
    
    compareCallback(result.count - 1, result.count - 1, true)
    
    return result
}

func doSelectionSortRecursive(_ input: [Int]) -> [Int] {
    if input.count <= 1 {
        return input //already sorted
    }
    var subArray = input
    let min = dropMin(&subArray)
    return [min] + doSelectionSortRecursive(subArray)
}

func dropMin(_ input: inout [Int]) -> Int {
    var minIndex = 0
    for i in 1..<input.count {
        if input[i] < input[minIndex] {
            minIndex = i
        }
    }
    return input.remove(at: minIndex)
}

//doSelectionSort([1])
//
//doSelectionSortRecursive([1111, 11, 111, 1111,111])
//doSelectionSortRecursive([1111, 1111, 1111, 1111, 1111, 1111, 1111, 1111, 1111])
//
//doSelectionSortRecursive([1, 1, -11, 5, 4, 2, 0, 6])


func randomDataSource(_ maxCount: Int) -> [Int] {
    var result: [Int] = []
    for _ in 0..<maxCount {
        result.append(Int.random(in: 1 ..< 100))
    }
    return result
}


import PlaygroundSupport

class SortView : UIView{
    
    private var barViews: [BarView] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.green
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setBars(_ bars: [Int]) {
        barViews.removeAll()
        
        for view in self.subviews {
            view.removeFromSuperview()
        }
        
        let width = (self.bounds.width - 2 * BarView.space) / CGFloat(bars.count)
        
        for (index, value) in bars.enumerated() {
            let bar = BarView(value, index: index, width: width)
            barViews.append(bar)
            self.addSubview(bar)
        }
    }
    
    func swapBar(index: Int, with newIndex: Int) {
        print("\(index) <-> \(newIndex)")
        
        var frame1 = barViews[index].frame
        var frame2 = barViews[newIndex].frame
        
        frame1.origin = CGPoint(x: barViews[newIndex].frame.minX, y: 0)
        frame2.origin = CGPoint(x: barViews[index].frame.minX, y: 0)
        
        let view1 = self.barViews[index]
        let view2 = self.barViews[newIndex]
        
        UIView.animate(withDuration: 0.8, animations: {
            view1.frame = frame1
            view2.frame = frame2
        }) { (completed) in
            view1.backgroundColor = UIColor.blue
            view2.backgroundColor = UIColor.white
        }
        
        barViews[index] = view2
        barViews[newIndex] = view1
        //
        
    }
    
    func compareBar(index: Int, with newIndex: Int) {
        
        print("\(index) ~ \(newIndex)")
        
        self.barViews[index].alpha = 0.2
        self.barViews[newIndex].alpha = 0.2
        
        self.barViews[index].backgroundColor = UIColor.blue
        self.barViews[newIndex].backgroundColor = UIColor.red
        
        //        self.barViews[index].backgroundColor = UIColor.lightGray
        //        self.barViews[newIndex].backgroundColor = UIColor.lightGray
        
        UIView.animate(withDuration: 0.8, delay: 0.1, options: .curveEaseInOut, animations: {
            self.barViews[index].alpha = 1.0
            self.barViews[newIndex].alpha = 1.0
            
        })
    }
    
    func fixBar(index: Int) {
        barViews[index].backgroundColor = UIColor.white
    }
}

class BarView : UIView {
    static let space: CGFloat = 2
    
    convenience init(_ height: Int, index: Int, width: CGFloat) {
        let frame = CGRect(x: BarView.space + width * CGFloat(index), y: 0, width: width, height: CGFloat(height) / 100 * 300)
        self.init(frame: frame)
        bounds = frame.insetBy(dx: BarView.space, dy: 0.0)
        backgroundColor = UIColor.blue
    }
}



var view = SortView(frame: CGRect(x: 0, y: 0, width: 600, height: 300))
let source = randomDataSource(30)

view.transform = CGAffineTransform(rotationAngle: .pi)
view.setBars(source)

DispatchQueue.global().async {
    doSelectionSort(source) { left, right, swap in
        DispatchQueue.main.async {
            if swap {
                view.swapBar(index: left, with: right)
            }else {
                view.compareBar(index: left, with: right)
            }
            
            //            view.fixBar(index: left)
        }
    }
}

PlaygroundPage.current.liveView = view
