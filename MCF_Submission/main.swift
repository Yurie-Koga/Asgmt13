//
//  main.swift
//  MCF_Submission
//
//  Created by Uji Saori on 2021-04-18.
//

import Foundation

public struct UF {
  /// parent[i] = parent of i
  private var parent: [Int]
  /// size[i] = number of nodes in tree rooted at i
  private var size: [Int]
  /// number of components
  private(set) var count: Int
  
  /// Initializes an empty union-find data structure with **n** elements
  /// **0** through **n-1**.
  /// Initially, each elements is in its own set.
  /// - Parameter n: the number of elements
  public init(_ n: Int) {
    self.count = n
    self.size = [Int](repeating: 1, count: n)
    self.parent = [Int](repeating: 0, count: n)
    for i in 0..<n {
      self.parent[i] = i
    }
  }
  
  /// Returns the canonical element(root) of the set containing element `p`.
  /// - Parameter p: an element
  /// - Returns: the canonical element of the set containing `p`
  public mutating func find(_ p: Int) -> Int {
    try! validate(p)
    var root = p
    while root != parent[root] { // find the root
      root = parent[root]
    }
    var p = p
    while p != root {
      let newp = parent[p]
      parent[p] = root  // path compression
      p = newp
    }
    return root
  }
  
  /// Returns `true` if the two elements are in the same set.
  /// - Parameters:
  ///   - p: one elememt
  ///   - q: the other element
  /// - Returns: `true` if `p` and `q` are in the same set; `false` otherwise
  public mutating func connected(_ p: Int, _ q: Int) -> Bool {
    return find(p) == find(q)
  }
  
  /// Merges the set containing element `p` with the set containing
  /// element `q`
  /// - Parameters:
  ///   - p: one element
  ///   - q: the other element
  public mutating func union(_ p: Int, _ q: Int) {
    let rootP = find(p)
    let rootQ = find(q)
    guard rootP != rootQ else { return } // already connected
    
    // make smaller root point to larger one
    if size[rootP] < size[rootQ] {
      parent[rootP] = rootQ
      size[rootQ] += size[rootP]
    } else {
      parent[rootQ] = rootP
      size[rootP] += size[rootQ]
    }
    count -= 1
  }
  
  private func validate(_ p: Int) throws {
    let n = parent.count
    guard p >= 0 && p < n else {
      throw RuntimeError.illegalArgumentError("index \(p) is not between 0 and \(n - 1)")
    }
  }
}

enum RuntimeError: Error {
    case illegalArgumentError(String)
}

func MST(_ pipes: [(u: Int, v: Int, w: Int, status: Bool)], _ nodes: Int)
        -> (cost: Int,
           mst: [(u: Int, v: Int, w: Int, status: Bool)],
           mstActives: [(u: Int, v: Int, w: Int, status: Bool)],
           mstInactives: [(u: Int, v: Int, w: Int, status: Bool)], inactiveCnt: Int) {
    
    var mstEdges = [(u: Int, v: Int, w: Int, status: Bool)]()
    var mstActives = [(u: Int, v: Int, w: Int, status: Bool)]()
    var mstInactives = [(u: Int, v: Int, w: Int, status: Bool)]()
    var uf = UF(nodes + 1)
    for edge in pipes {
        if uf.connected(edge.u, edge.v) { continue }
        uf.union(edge.u, edge.v)
        mstEdges.append(edge)
        if edge.status {
            mstActives.append(edge)
        } else {
            mstInactives.append(edge)
        }
    }
    
    return (mstEdges.map { $0.w }.reduce(0, +), mstEdges, mstActives, mstInactives, mstInactives.count)
}

func readNext(inputLines: inout [String]) -> String {
    let nextLine = inputLines[0]
    inputLines.remove(at: 0)
    return String(nextLine)
}

func solution(inputLines: inout [String]?) {
    let firstLine = inputLines == nil ?
        readLine()!.split(separator: " ").map { Int($0)! }
        : readNext(inputLines: &inputLines!).split(separator: " ").map { Int($0)! }
    let n = firstLine[0]
    let m = firstLine[1]
    let d = firstLine[2]
    
    var activePipes = [(u: Int, v: Int, w: Int, status: Bool)]()
    var dayCount = 0
    
    // inital active pipes
    var row = [Int]()
    for _ in 0..<n - 1 {
        row = inputLines == nil ?
            readLine()!.split(separator: " ").map { Int($0)! }
            : readNext(inputLines: &inputLines!).split(separator: " ").map { Int($0)! }
        activePipes.append((u: row[0], v: row[1], w: row[2], status: true))
    }
    activePipes.sort { $0.w < $1.w }

    // inactive pipes
    var inactivePipes = [(u: Int, v: Int, w: Int, status: Bool)]()
    for _ in 0..<(m - (n - 1)) {
        row = inputLines == nil ?
            readLine()!.split(separator: " ").map { Int($0)! }
            : readNext(inputLines: &inputLines!).split(separator: " ").map { Int($0)! }
        inactivePipes.append((u: row[0], v: row[1], w: row[2], status: false))
    }
    inactivePipes.sort { $0.w < $1.w }
    
    // MST
    var allPipes = activePipes + inactivePipes
    allPipes.sort { $0.w < $1.w }
    let mst = MST(allPipes, n)
    dayCount = mst.inactiveCnt
    
    // enhancer
//    if (d > 0) {
//        for i in 0..<activePipes.count {
//            var checkPipes = activePipes
//            checkPipes[i].w = max(0, activePipes[i].w - d)
//            // calculate again
//            allPipes = checkPipes + inactivePipes
//            allPipes.sort { $0.w < $1.w }
//            let checkMst = MST(allPipes, n)
//            if checkMst.cost < mst.cost {
//                dayCount -= 1
//                break
//            }
//        }
//    }
    
    print(dayCount)
}


// make sure you run the function (before you submit)
var input: [String]? = [String]()
solution(inputLines: &input)
