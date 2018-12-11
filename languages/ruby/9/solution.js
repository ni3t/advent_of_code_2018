// Marble Ring Problem
// The first approach with arrays took ways too long to solve. Here is the
// linked list approach, lets see.

/**
 * Representing a ring list: a linked list that always forms a closed ring
 */
class RingList {
  constructor(value = 0) {
    this.actNode = new Node(value);
    this.actNode.prev = this.actNode;
    this.actNode.next = this.actNode;
  }

  /**
   * Inserts a new value nrOfNodes to the "right" (clockwise).
   * Also updates the actNode to the newly inserted node.
   */
  insertValueNextAfter(value, nrOfNodes = 0) {
    let act = this.actNode;
    while (nrOfNodes > 0) {
      act = act.next;
      nrOfNodes--;
    }
    let newNode = new Node(value);
    this.insertNodeAfter(newNode, act);
    this.actNode = newNode;
    return newNode;
  }

  /**
   * Moves the actual node nrOfNodes to the "left" (counter-clockwise),
   * and returns the new act node
   */
  rewind(nrOfNodes) {
    let act = this.actNode;
    while (nrOfNodes > 0) {
      act = act.prev;
      nrOfNodes--;
    }
    this.actNode = act;
    return this.actNode;
  }

  /**
   * Inserts a node after the given node. Standard linked list method.
   */
  insertNodeAfter(insertNode, afterNode) {
    insertNode.prev = afterNode;
    insertNode.next = afterNode.next;
    afterNode.next = insertNode;
    insertNode.next.prev = insertNode;
  }

  /**
   * Removes the actual node, setting the node to the right (next, clockwise)
   * as the actual node.
   */
  removeActNode() {
    let node = this.actNode;
    node.prev.next = node.next;
    node.next.prev = node.prev;
    this.actNode = node.next;
    node.next = null;
    node.prev = null;
    return node;
  }

  /**
   * Prints the actual ring, starting at the actual node
   */
  printList() {
    let act = this.actNode;
    let out = [];
    while (true) {
      out.push(act.value);
      act = act.next;
      if (act === this.actNode) {
        break;
      }
    }
    console.log(out);
  }
}

/**
 * A simple double-linked list node
 */
class Node {
  constructor(value, prev = null, next = null) {
    this.value = value;
    this.prev = prev;
    this.next = next;
  }
}

// ------------------- Test input -----------------------
let inputsTest = {
  player: 0,
  nrOfPlayers: 13,
  playerScores: new Array(13),
  maxScore: 0,
  maxScoreIndex: -1,
  marbleMax: 7999,
  marble: 1
};

// ------------------ Input for solution 1 ------------------
let inputsSolution1 = {
  player: 0,
  nrOfPlayers: 447,
  playerScores: new Array(447),
  maxScore: 0,
  maxScoreIndex: -1,
  marbleMax: 71510,
  marble: 1
};

// ------------------ Input for solution 2 ------------------
let inputsSolution2 = {
  player: 0,
  nrOfPlayers: 435,
  playerScores: new Array(447),
  maxScore: 0,
  maxScoreIndex: -1,
  marbleMax: 71184 * 100,
  marble: 1
};

/**
 * The actual solving routine - with a ring list this is quite straight forward
 */
function playMarbleGame(inputs) {
  let {
    player,
    nrOfPlayers,
    playerScores,
    maxScore,
    maxScoreIndex,
    marbleMax,
    marble
  } = inputs;
  let solution = { maxScore: 0, maxPlayerIndex: -1 };
  let ring = new RingList(0);

  while (marble <= marbleMax) {
    if (marble % 23 > 0) {
      ring.insertValueNextAfter(marble, 1);
    } else {
      let removeNode = ring.rewind(7);
      playerScores[player] =
        (playerScores[player] || 0) + marble + removeNode.value;
      if (playerScores[player] > maxScore) {
        maxScore = playerScores[player];
        maxScoreIndex = player;
      }
      ring.removeActNode();
    }
    marble++;
    player = (player + 1) % nrOfPlayers;
  }
  return { maxScore, maxPlayerIndex: maxScoreIndex };
}

// let outputTest = playMarbleGame(inputsTest);
// console.log(
//   `Day 9: Highest player score (Sample): ${
//     outputTest.maxScore
//   } from Player ${outputTest.maxPlayerIndex + 1}`
// );

// let output1 = playMarbleGame(inputsSolution1);
// console.log(
//   `Day 9: Highest player score (Solution 1): ${
//     output1.maxScore
//   } from Player ${output1.maxPlayerIndex + 1}`
// );

let output2 = playMarbleGame(inputsSolution2);
console.log(
  `Day 9: Highest player score (Solution 2): ${
    output2.maxScore
  } from Player ${output2.maxPlayerIndex + 1}`
);
