    async function mostrarDetalle(id) {
      const res = await fetch(`/api/personaje/${id}`);
      const data = await res.json();
      const cont = document.getElementById("detalle");

      if (data.error) {
        cont.innerHTML = `<h2>Error al cargar personaje</h2>`;
        return;
      }

      cont.innerHTML = `
        <img src="/static/img/personaje01.png" alt="Personaje">
        <h2>${data.nombre}</h2>
        <p><b>Clase:</b> ${data.clase}</p>
        <p><b>Nivel:</b> ${data.nivel}</p>
      `;
    }

    function openModal() {
      document.getElementById("formPersonaje").reset();
      document.getElementById("id_personaje").value = "";
      document.getElementById("tituloModal").innerText = "Nuevo Personaje";
      document.getElementById("modalAgregar").style.display = "block";
    }

    function closeModal() {
      document.getElementById("modalAgregar").style.display = "none";
    }

    function editarPersonaje(id, nombre, clase) {
      document.getElementById("id_personaje").value = id;
      document.getElementById("nombre").value = nombre;
      document.getElementById("clase").value = clase;
      document.getElementById("tituloModal").innerText = "Editar Personaje";
      document.getElementById("modalAgregar").style.display = "block";
    }

    async function eliminarPersonaje(id) {
      if (confirm("¿Seguro que deseas eliminar este personaje?")) {
        const res = await fetch(`/eliminar_personaje/${id}`, { method: "DELETE" });
        if (res.ok) location.reload();
        else alert("Error al eliminar personaje.");
      }
    }

    async function seleccionarPersonaje(id) {
      const res = await fetch(`/seleccionar_personaje/${id}`, { method: "POST" });
      if (res.ok) alert("✅ Personaje seleccionado correctamente.");
      else alert("Error al seleccionar personaje.");
    }
  