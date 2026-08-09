-- 0005_usuario_rol_autoconsulta.sql — V10-ESQUEMA-SQL §19.2, Corrección 4
--
-- Hallazgo de la rebanada 1, verificado contra Postgres real: para saber a
-- qué empresas pertenece un usuario (el primer paso después de iniciar
-- sesión, antes de que exista cualquier empresa activa) hace falta leer
-- usuario_rol SIN tener todavía un app.empresa_id que fijar — es una
-- consulta entre empresas, legítima sólo para el propio usuario.
--
-- La política genérica de aislamiento (empresa_id = app.empresa_id) sigue
-- gobernando TODO lo demás, incluida cualquier escritura sobre esta misma
-- tabla: esta política nueva es adicional, sólo para SELECT, y sólo abre
-- las filas del propio usuario autenticado.

create policy p_usuario_rol_autoconsulta on usuario_rol
  for select
  using (usuario_id = current_setting('app.usuario_id', true));
