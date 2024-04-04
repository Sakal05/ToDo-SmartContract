// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ToDo} from "../src/ToDo.sol";

contract TodoTest is Test {
    ToDo public todo;

    event CreateTask(
        uint256 indexed index,
        address indexed creator,
        string taskName,
        bool completed,
        uint256 createdAt,
        uint256 updatedAt
    );
    event TaskShared(address indexed creator, uint256 taskIndex, address sharedWith);

    struct TodoInfo {
        uint256 id;
        string taskName;
        bool completed;
        uint256 createdAt;
        uint256 updatedAt;
    }

    // TodoInfo[] public mockTaskLists = [
    //     TodoInfo({id: 0, taskName: "Clean House", completed: false, createdAt: block.timestamp, updatedAt: block.timestamp}),
    //     TodoInfo({
    //         id: 1,
    //         taskName: "Project Set Up",
    //         completed: false,
    //         createdAt: block.timestamp,
    //         updatedAt: block.timestamp
    //     }),
    //     TodoInfo({
    //         id: 2,
    //         taskName: "Workshop Planning",
    //         completed: false,
    //         createdAt: block.timestamp,
    //         updatedAt: block.timestamp
    //     }),
    //     TodoInfo({
    //         id: 3,
    //         taskName: "Environements Set Up",
    //         completed: false,
    //         createdAt: block.timestamp,
    //         updatedAt: block.timestamp
    //     })
    // ];

    address[] public sharedAddresses = [address(11), address(22), address(33), address(44)];

    function setUp() public {
        todo = new ToDo();
    }

    function testCreateTask() public {
        vm.startPrank(address(1));
        // vm.expectEmit(address(todo));
        vm.expectEmit(true, true, false, true, address(todo)); // Asserting CreateTask event
        emit ToDo.CreateTask(0, address(1), "Clean house", false, block.timestamp, block.timestamp);
        todo.createTask(
            "Clean house",
            sharedAddresses // Access elements using square brackets []
        );

        // for (uint256 i = 0; i < sharedAddresses.length; i++) {
        //     vm.expectEmit(true, false, false, true, address(todo)); // Asserting TaskShared events
        // }

        vm.stopPrank();
    }
}
