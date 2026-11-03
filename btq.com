return;
    }

    /* в корзину */
    var addBtn = e.target.closest('[data-add]');
    if (addBtn) {
      addItem(
        addBtn.dataset.id,
        addBtn.dataset.name,
        Number(addBtn.dataset.price),
        addBtn.dataset.meta,
        addBtn.dataset.cat,
        addBtn.dataset.type || 'phone'
      );
      return;
    }

    var qtyBtn = e.target.closest('[data-qty]');
    if (qtyBtn) {
      var k = qtyBtn.dataset.key;
      cartItems.forEach(function (i) {
        if (i.key !== k) return;
        if (qtyBtn.dataset.qty === 'inc') i.qty += 1;
        else i.qty = Math.max(0, i.qty - 1);
      });
      cartItems = cartItems.filter(function (i) { return i.qty > 0; });
      save();
      renderCart();
      return;
    }

    var rm = e.target.closest('[data-remove]');
    if (rm) {
      cartItems = cartItems.filter(function (i) { return i.key !== rm.dataset.remove; });
      save();
      renderCart();
      toast('Товар удалён из корзины');
      return;
    }

    if (e.target.closest('#goShop')) {
      closeCart();
      var shop = $('#shop');
      if (shop) shop.scrollIntoView({ behavior: 'smooth', block: 'start' });
      return;
    }

    if (e.target.closest('#checkout')) {
      orderTotal = total();
      cartItems = [];
      save();
      renderCart();
      updateBadge();
      toast('Заказ оформлен — ждите звонка менеджера');
      return;
    }

    if (e.target.closest('#doneBtn')) { closeCart(); return; }
    if (e.target.closest('#cartBtn')) { openCart(); return; }
    if (e.target.closest('#cartClose') || e.target === scrim) { closeCart(); }
  });

  /* hero buy */
  var heroBuy = $('#heroBuy');
  if (heroBuy) {
    heroBuy.addEventListener('click', function () {
      addItem('pm', 'iPhone 17 Pro Max', 749990, '256 ГБ · титан', 'iPhone', 'phone');
      openCart();
    });
  }

  /* header state */
  var hdr = $('#hdr');
  window.addEventListener('scroll', function () {
    hdr.classList.toggle('scrolled', window.scrollY > 12);
  }, { passive: true });

  /* mobile menu */
  var mnav = $('#mnav');
  var menuBtn = $('#menuBtn');
  function closeMenu() {
    mnav.classList.add('hidden');
    menuBtn.setAttribute('aria-expanded', 'false');
  }
  menuBtn.addEventListener('click', function () {
    var hidden = mnav.classList.contains('hidden');
    mnav.classList.toggle('hidden', !hidden);
    menuBtn.setAttribute('aria-expanded', String(hidden));
  });
  $$('.mnav-a').forEach(function (a) { a.addEventListener('click', closeMenu); });

  /* escape */
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape') {
      if (cartEl.classList.contains('on')) closeCart();
      else if (!mnav.classList.contains('hidden')) closeMenu();
    }
  });

  /* ================= boot ================= */
  renderShowcase();
  renderCompare();
  renderShop();
  renderCart();
  observeReveals();
  collectWraps();
  parallax();
  window.addEventListener('load', function () { collectWraps(); parallax(); });
  window.addEventListener('resize', function () { parallax(); });
})();
</script>
</body>
</html>