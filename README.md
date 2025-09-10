			Mini Streaming — SQL+Python

			О проекте
Учебный мини-стриминг: пользователи смотрят контент, ставят оценки и оформляют подписки. Тарифы ведём с историей версий (SCD2) — можно отвечать «что действовало на дату X».

			Модели
- Концептуальная: `docs/conceptual-model.mmd`
- Логическая (3НФ + SCD2): `docs/logical-model.mmd`
- Обоснования физической модели: `docs/physical-model.md` (коротко про 3НФ/SCD2 и будущие ограничения)

			Как запустить локально
1. Python 3.11+  
2. Создать окружение и установить зависимости:
   ```bash
   python -m venv .venv
   .\.venv\Scripts\activate
   pip install -r requirements.txt
