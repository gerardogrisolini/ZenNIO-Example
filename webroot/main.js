var token = localStorage.getItem('token');

function unauthorized() {
    alert('401 - Unauthorized');
    localStorage.removeItem('token')
    location.href = '/auth';
}

function updateDevice(data) {
    data.id = parseInt(data.id);
    fetch('/api/device', {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method: 'PUT',
            //mode: 'cors',
        cache: 'no-cache',
        body: JSON.stringify(data)
    })
    .then(response => response.status == 401 ? unauthorized() : response.json())
    .then(json => json)
    .catch(error => console.log(error));
}

function deleteDevice(row) {
    var id = row.getData().id
    fetch('/api/device/' + id, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method: 'DELETE',
            //mode: 'cors',
        cache: 'no-cache'
    })
    .then(response => response.status == 401 ? unauthorized() : response)
    .then(response => row.delete())
    .catch(error => console.log(error));
}

var table;

function getDevices() {
    if (token == null) {
        location.href = '/auth';
        return;
    }
    
    var config = {
        height:"auto",
        selectable:1,          //selectable rows
        layout:"fitColumns",      //fit columns to width of table
        responsiveLayout:"hide",  //hide columns that dont fit on the table
        tooltips:false,            //show tool tips on cells
        addRowPos:"top",          //when adding a new row, add it to the top of the table
        history:false,             //allow undo and redo actions on the table
        pagination:"local",       //paginate the data
        paginationSize:20,         //allow 7 rows per page of data
        movableColumns:false,      //allow column order to be changed
        resizableRows:false,       //allow row order to be changed
        initialSort:[             //set the initial sort order of the data
            {column:"id", dir:"asc"},
        ],
        placeholder:"No Data Set",
//        rowClick: function(e, row) { // Trigger an alert message when the row is clicked.
//            alert("Row " + row.getData().id + " Clicked!");
//        },
//        cellEdited:function(cell) {
//            updateDevice(cell.getRow().getData());
//        },
        columns:[
                {title:"Id", field:"id", sorter:"number", headerFilter:true, validator:"required"},
                {title:"Name", field:"name", sorter:"string", headerFilter:true, validator:"required"},
                {title:"MacAddress", field:"macAddress", sorter:"string", headerFilter:true, validator:"required"},
                {title:"System", field:"system", orter:"string", headerFilter:true, validator:"required"},
                {title:"Version", field:"version", orter:"string", headerFilter:true, validator:"required"},
                {title:"Delete", formatter:"buttonCross", width:100, align:"center", headerSort:false, cellClick:function(e, cell) {
                        if (confirm('Are you sure you want to delete this entry?')) {
                            deleteDevice(cell.getRow());
                        }
                    }
                },
         ],
    }
    
    table = new Tabulator("#content", config);
    table.setData("/api/device");
    
    var btn = document.createElement("BUTTON");
    btn.setAttribute("title", "Reboot");
    btn.setAttribute("class", "tabulator-page");
    btn.setAttribute("style", "float: left");
    btn.onclick = function() {
        executeOnDevice("reboot")
    };
    
    var t = document.createTextNode("Reboot");
    btn.appendChild(t);
    document.getElementsByClassName("tabulator-paginator")[0].prepend(btn);
}

function executeOnDevice(method) {
    var selectedRows = table.getSelectedData();
    var macAddress = selectedRows[0].macAddress;
    var model = { method: method, data: "" };
    fetch('/api/device/' + macAddress, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method : 'POST',
        //mode: 'cors',
        cache: 'no-cache',
        body: JSON.stringify(model)
    })
    .then(response => response.status == 401 ? unauthorized() : response)
    .catch(error => console.log(error));
}
