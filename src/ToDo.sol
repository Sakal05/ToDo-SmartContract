// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract ToDo {
    struct TodoInfo {
        uint256 id;
        string taskName;
        bool completed;
        uint256 createdAt;
        uint256 updatedAt;
    }

    event CreateTask(
        uint256 indexed index,
        address indexed creator,
        string taskName,
        bool completed,
        uint256 createdAt,
        uint256 updatedAt
    );
    event TaskCompleted(uint256 indexed taskId, bool status, uint256 updatedAt);
    event TaskShared(address indexed creator, uint256 taskIndex, address sharedWith);

    error UnAuthorized();
    error TaskAlreadyCompleted();

    // mapping of todoInfo index to creator
    mapping(address => TodoInfo[]) private userTaskInfo;
    // mapping of creator to task to sharedUser
    mapping(address => mapping(uint256 => address[])) private sharedTaskUser;

    modifier onlyOwner(address caller) {
        if (msg.sender != caller) {
            revert UnAuthorized();
        }
        _;
    }

    function createTask(string calldata task, address[] memory _sharedWith) external {
        TodoInfo memory newTask = TodoInfo({
            id: userTaskInfo[msg.sender].length,
            taskName: task,
            completed: false,
            createdAt: block.timestamp,
            updatedAt: block.timestamp
        });

        userTaskInfo[msg.sender].push(newTask);

        emit CreateTask(
            userTaskInfo[msg.sender].length - 1, msg.sender, task, newTask.completed, block.timestamp, block.timestamp
        );
        // Share the task with specified addresses
        if (_sharedWith.length > 0) {
            for (uint256 i = 0; i < _sharedWith.length; i++) {
                sharedTaskUser[msg.sender][newTask.id] = _sharedWith;
                emit TaskShared(msg.sender, userTaskInfo[msg.sender].length - 1, _sharedWith[i]);
            }
        }
    }

    function getMyTasks() external view returns (TodoInfo[] memory myToDoInfos) {
        uint256 myTaskLength = userTaskInfo[msg.sender].length;
        myToDoInfos = new TodoInfo[](myTaskLength);

        for (uint256 i = 0; i < myTaskLength; i++) {
            myToDoInfos[i] = userTaskInfo[msg.sender][i];
        }

        return myToDoInfos;
    }

    function getSharedTasks(address _creator) external view returns (TodoInfo[] memory mySharedTasks) {
        uint256 count = 0;
        uint256 creatorTaskLength = userTaskInfo[_creator].length;
        // uint256[] memory createTaskIds = new uint256[](creatorTaskLength);

        for (uint256 i = 0; i < creatorTaskLength; i++) {
            for (uint256 j = 0; j < sharedTaskUser[_creator][i].length; j++) {
                if (sharedTaskUser[_creator][i][j] == msg.sender) {
                    count++;
                }
            }
        }

        mySharedTasks = new TodoInfo[](count);

        for (uint256 i = 0; i < creatorTaskLength; i++) {
            for (uint256 j = 0; j < sharedTaskUser[_creator][i].length; j++) {
                if (sharedTaskUser[_creator][i][j] == msg.sender) {
                    mySharedTasks[i] = userTaskInfo[_creator][i];
                }
            }
        }

        return mySharedTasks;
    }

    function checkedSharedTask(address _creator, uint256 taskId) public view returns (bool) {
        for (uint256 j = 0; j < sharedTaskUser[_creator][taskId].length; j++) {
            if (sharedTaskUser[_creator][taskId][j] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function markAsCompleted(address _creator, uint256 _taskIndex) external {
        require(_creator != address(0) && _taskIndex < userTaskInfo[_creator].length, "Invalid task");
        if (msg.sender != _creator && checkedSharedTask(_creator, _taskIndex) == false) {
            revert UnAuthorized();
        }

        TodoInfo storage task = userTaskInfo[_creator][_taskIndex];

        if (task.completed == true) {
            revert TaskAlreadyCompleted();
        }

        task.completed = true;
        task.updatedAt = block.timestamp;

        emit TaskCompleted(_taskIndex, task.completed, block.timestamp);
    }
}
