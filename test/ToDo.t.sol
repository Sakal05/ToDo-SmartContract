// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ToDo} from "../src/ToDo.sol";
import "forge-std/console.sol";

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

    address[] public sharedAddresses = [address(11), address(22), address(33), address(44)];

    function setUp() public {
        todo = new ToDo();
    }

    function testCreateTask() public {
        vm.startPrank(address(1));

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

    function testGetTasks() public {
        vm.startPrank(address(1));
        todo.createTask(
            "Clean house",
            sharedAddresses // Access elements using square brackets []
        );

        assertEq(todo.getMyTasks()[0].taskName, "Clean house");
        vm.stopPrank();
    }

    function testReturnNoTasks() public {
        vm.startPrank(address(1));

        assertEq(todo.getMyTasks().length, 0);
        assertEq(todo.getSharedTasks(address(1)).length, 0);
    }

    function testGetSharedTasks() public {
        vm.startPrank(address(1));
        todo.createTask(
            "Clean house",
            sharedAddresses // Access elements using square brackets []
        );
        todo.createTask(
            "wash car",
            sharedAddresses // Access elements using square brackets []
        );
        // change caller to shared addrerss
        vm.startPrank(address(11));
        ToDo.TodoInfo[] memory sharedTasks = todo.getSharedTasks(address(1));
        assertEq(sharedTasks.length, 2);
        console.log("Shared tasks", sharedTasks[0].completed);
        assertEq(sharedTasks[0].completed, false);
        vm.stopPrank();
    }

    function testMarkTaskCompleteByCreator() public {
        address _creator = address(1);
        uint256 _taskId = 1;

        vm.startPrank(address(1));
        todo.createTask("Clean house", sharedAddresses);
        todo.createTask("Clean house", sharedAddresses);
        todo.createTask("wash car", sharedAddresses);
        assertEq(todo.getMyTasks().length, 3);

        todo.markAsCompleted(_creator, _taskId);

        ToDo.TodoInfo[] memory myTask = todo.getMyTasks();

        assertEq(myTask[1].completed, true);
        assertEq(myTask[2].completed, false);
        assertEq(myTask[0].completed, false);

        assertEq(myTask[1].updatedAt, block.timestamp);
    }

    function testMarkTaskCompleteBySharedAddress() public {
        address _creator = address(1);
        uint256 _taskId = 1;

        vm.startPrank(address(1));
        todo.createTask("Clean house", sharedAddresses);
        todo.createTask("Clean house", sharedAddresses);
        todo.createTask("wash car", sharedAddresses);
        assertEq(todo.getMyTasks().length, 3);

        vm.startPrank(sharedAddresses[1]);
        vm.expectEmit(true, false, false, true);
        emit ToDo.TaskCompleted(_taskId, true, block.timestamp);
        todo.markAsCompleted(_creator, _taskId);

        vm.startPrank(address(1));

        ToDo.TodoInfo[] memory myTask = todo.getMyTasks();
        assertEq(myTask[_taskId].completed, true);
    }

    function testExpectRevertUnauthorized() public {
        vm.startPrank(address(1));
        todo.createTask("Clean EyKe", sharedAddresses);
        todo.createTask("Clean house", sharedAddresses);
        todo.createTask("wash car", sharedAddresses);

        vm.startPrank(address(86));
        vm.expectRevert(ToDo.UnAuthorized.selector);
        todo.markAsCompleted(address(1), 0);
    }

    function testExpectRevertInvalidTask() public {
        vm.startPrank(address(1));
        todo.createTask("Clean EyKe", sharedAddresses);
        todo.createTask("Clean house", sharedAddresses);
        todo.createTask("wash car", sharedAddresses);

        vm.expectRevert(bytes("Invalid task"));
        todo.markAsCompleted(address(0), 0);
        vm.expectRevert(bytes("Invalid task"));
        todo.markAsCompleted(address(1), 34);
        vm.expectRevert(bytes("Invalid task"));
        todo.markAsCompleted(address(0), 34);
    }

    function testExpectRevertTaskAlreadyCompleted() public {
        vm.startPrank(address(1));
        todo.createTask("Clean EyKe", sharedAddresses);
        todo.createTask("Clean house", sharedAddresses);
        todo.createTask("wash car", sharedAddresses);

        todo.markAsCompleted(address(1), 0);
        vm.expectRevert(ToDo.TaskAlreadyCompleted.selector);
        todo.markAsCompleted(address(1), 0);
    }

    function testEmitEventTaskComplete() public {
        vm.startPrank(address(1));

        todo.createTask("Clean EyKe", sharedAddresses);
        todo.createTask("Clean house", sharedAddresses);
        todo.createTask("wash car", sharedAddresses);

        vm.expectEmit(true, false, false, true);
        emit ToDo.TaskCompleted(0, true, block.timestamp);
        todo.markAsCompleted(address(1), 0);
    }
}
