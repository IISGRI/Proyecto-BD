    async function mostrarDetalle(id) {
      const res = await fetch(`/api/mascota/${id}`);
      const data = await res.json();
      const cont = document.getElementById("detalle");

      if (data.error) {
        cont.innerHTML = `<h2>Error al cargar mascota</h2>`;
        return;
      }

      cont.innerHTML = `
        <img src="/static/img/mascota01.png" alt="Mascota">
        <h2>${data.nombre}</h2>
        <p><b>Tipo:</b> ${data.tipo}</p>
        <p><b>Nivel:</b> ${data.nivel}</p>
      `;
    }

    function openModal() {
      document.getElementById("formMascota").reset();
      document.getElementById("id_mascota").value = "";
      document.getElementById("tituloModal").innerText = "Nueva Mascota";
      document.getElementById("modalAgregar").style.display = "block";
    }

    function closeModal() {
      document.getElementById("modalAgregar").style.display = "none";
    }

    function editarMascota(id, nombre, tipo) {
      document.getElementById("id_mascota").value = id;
      document.getElementById("nombre").value = nombre;
      document.getElementById("tipo").value = tipo;
      document.getElementById("tituloModal").innerText = "Editar Mascota";
      document.getElementById("modalAgregar").style.display = "block";
    }

    async function eliminarMascota(id) {
      if (confirm("¿Seguro que deseas eliminar esta mascota?")) {
        const res = await fetch(`/eliminar_mascota/${id}`, { method: "DELETE" });
        if (res.ok) location.reload();
        else alert("Error al eliminar mascota.");
      }
    }

    async function seleccionarMascota(id) {
      const res = await fetch(`/seleccionar_mascota/${id}`, { method: "POST" });
      if (res.ok) alert("✅ Mascota seleccionada correctamente.");
      else alert("Error al seleccionar mascota.");
    }
  