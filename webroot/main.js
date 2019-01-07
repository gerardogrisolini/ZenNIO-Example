var token = localStorage.getItem('token');

function savePerson() {
    const id = document.getElementById("id").value;
    const firstName = document.getElementById("firstName").value;
    const lastName = document.getElementById("lastName").value;
    const email = document.getElementById("email").value;
    if (id === '' || firstName === '' || lastName == '' || email == '') { return; }
    const json = JSON.stringify({
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email
    });
    if (id === '00000000-0000-0000-0000-000000000000') {
        insertPerson(json);
    } else {
        updatePerson(id, json)
    }
}

function insertPerson(json) {
    fetch('/api/person', {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method : 'POST',
        cache: 'no-cache',
        body: json
    })
    .then(response => response.status == 401 ? alert('401 - Unauthorized') : response.json())
    .then(json => location.reload())
    .catch(error => console.log(error));
}

function updatePerson(id, json) {
    fetch('/api/person/' + id, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method : 'PUT',
        cache: 'no-cache',
        body: json
    })
    .then(response => response.status == 401 ? alert('401 - Unauthorized') : response.json())
    .then(json => location.reload())
    .catch(error => console.log(error));
}

function deletePerson(id) {
    fetch('/api/person/' + id, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8',
            'Authorization': token
        },
        method : 'DELETE',
        cache: 'no-cache'
    })
    .then(response => response.status == 401 ? alert('401 - Unauthorized') : response)
    .then(response => location.reload())
    .catch(error => console.log(error));
}

function getPerson(id) {
    fetch('/api/person/' + id, {
        headers: {
            'Content-Type': 'application/json;charset=UTF-8'
        },
        method : 'GET',
        cache: 'no-cache'
    })
    .then(response => response.json())
    .then(json => selectPerson(json.id, json.firstName, json.lastName, json.email))
    .catch(error => console.log(error));
}

function selectPerson(id, firstName, lastName, email) {
    document.getElementById("id").value = id;
    document.getElementById("firstName").value = firstName;
    document.getElementById("lastName").value = lastName;
    document.getElementById("email").value = email;
}

/*
function getPersons() {
    document.getElementById('content').innerHTML = '';
    fetch('http://192.168.1.10:8080/api/person', {
        headers: {
            'Origin': '*',
            'Content-Type': 'application/json;charset=UTF-8'
        },
        method : 'GET',
        cache: 'no-cache',
        mode: 'cors'
    })
    .then(response => response.json())
    .then(json => showPersons(json))
    .catch(error => console.log(error));
}

function showPersons(json) {
    for (i = 0; i < json.length; i++) {
        div = json[i].firstName + ' ' + json[i].lastName;
        div += ' <button onclick="selectPerson(\'' + json[i].id + '\', \'' + json[i].firstName + '\', \'' + json[i].lastName + '\', \'' + json[i].email + '\')">Edit</button>';
        div += ' <button onclick="getPerson(\'' + json[i].id + '\')">Open</button>';
        div += ' <button onclick="deletePerson(\'' + json[i].id + '\')">Delete</button>';
        document.getElementById('content').innerHTML += div;
    }
}
*/

